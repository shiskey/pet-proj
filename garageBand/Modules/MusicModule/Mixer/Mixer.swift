//
//  Mixer.swift
//  garageBand
//
//  Created by mark on 31/01/2022.
//  Copyright © 2022 mark All rights reserved.
//

import Foundation
import AudioKit
import MediaPlayer

private enum MixerState {
    case shouldStart
    case shouldResume
    case playing
    case shouldPause
    case paused
    case shouldStop
    case stopped
}

class Mixer: MusicMixerProtocol {

    var presenter: MusicPresenterProtocol?

    private let bpm: Int
    private let pad: AKPlayer
    private let finalChord: AKPlayer
    private let tail: AKPlayer
    private let leadsInstruments: [AKPlayer]
    private let leadBells: [AKPlayer]
    private let bassInstruments: [AKPlayer]
    private let bassBells: [AKPlayer]

    private var barTime: Double { return 60.0 / (self.bpm/4.0) }
    private var totalBars: Int { return Int(round(self.pad.duration / self.barTime)) }
    private var progress: CGFloat { return self.currentBar.cgFloat / self.totalBars.cgFloat }
    private var currentBar: Int = 0
    private var timer: Timer?
    private var queueToPlay = Set<AKNode>()
    private var queueToStop = Set<AKNode>()
    private var allInstruments: [AKPlayer] { return self.leadsInstruments + self.bassInstruments }
    private var pausedTime: Double = -1.0
    private var state: MixerState = .shouldStart

    private var leadReverb: AKReverb = AKReverb.init(nil, dryWetMix: 0.5)
    private var bassReverb: AKReverb = AKReverb.init(nil, dryWetMix: 0.5)
    private lazy var leadsMixer: AKMixer = {
        let leadMixerInputs = self.leadsInstruments + self.leadBells
        let m = AKMixer(leadMixerInputs)
        return m
    }()
    private lazy var bassMixer: AKMixer = {
        let bassMixerInputs = self.bassInstruments + self.bassBells
        let m = AKMixer(bassMixerInputs)
        return m
    }()
    private var leadAmplitudeTracker: AKAmplitudeTracker!
    private var bassAmplitudeTracker: AKAmplitudeTracker!
    private var metronome: AKMetronome!
    private lazy var master: AKMixer = {
        // init metronome
        self.metronome = AKMetronome()
        self.metronome.tempo = Double(self.bpm)

        self.leadAmplitudeTracker = AKAmplitudeTracker(self.leadsMixer)
        self.bassAmplitudeTracker = AKAmplitudeTracker(self.bassMixer)
        self.leadAmplitudeTracker.connect(to: self.leadReverb)
        self.bassAmplitudeTracker.connect(to: self.bassReverb)

        let m = AKMixer(
            self.metronome,
            self.pad,
            self.finalChord,
            self.tail,
            self.leadReverb,
            self.bassReverb
        )

        return m
    }()

    required init(trackBundle: TrackBundle) {

        // setup audio tracks
        self.bpm = trackBundle.bpm
        self.pad = AudioFabric.loop(fileName: trackBundle.mainPad)
        self.finalChord = AudioFabric.loop(fileName: trackBundle.finalChord, shouldBuffer: true)
        self.tail = AudioFabric.loop(fileName: trackBundle.tail, shouldLooping: true, shouldBuffer: true)
        self.leadsInstruments = trackBundle.leadLoops.map { AudioFabric.loop(fileName: $0.audioName, shouldLooping: true) }
        self.leadBells = trackBundle.leadLoops.map({ AudioFabric.loop(fileName: $0.audioBell) })
        self.bassInstruments = trackBundle.bassLoops.map { AudioFabric.loop(fileName: $0.audioName, shouldLooping: true) }
        self.bassBells = trackBundle.bassLoops.map({ AudioFabric.loop(fileName: $0.audioBell) })

        // setup reverb
        self.setReverbPreset(trackBundle.reverbPreset)
        self.setReverbDryWet(trackBundle.reverbDryWet)

        // setup output
        AKSettings.playbackWhileMuted = true
        AKManager.output = self.master
        try! AKManager.start()
//        AudioKit.output = self.master
//        try! AudioKit.start()

        // start timeline timer
//        self.metronome.start()
        self.timer = Timer.scheduledTimer(
            timeInterval: self.barTime,
            target: self,
            selector: #selector(timeline),
            userInfo: nil,
            repeats: true
        )

    }

    deinit {
        try! AKManager.stop()
    }

    @objc func timeline() {

        if self.state == .shouldStart {
            self.state = .playing
            self.pausedTime = 0.0
            self.queueToPlay.remove(self.pad)
            self.presenter?.didStartTrack()
        }
        if self.state == .shouldPause {
            self.state = .paused
            // pause pads
            self.pausedTime = self.pad.currentTime.rounded()
            self.pad.fadeOutAndStop(time: 0.1)
            // also stop all loops
            self.stopInstruments()
            // remove from queue
            self.queueToStop.remove(self.pad)
            // call presenter
            self.presenter?.didPauseTrack()
        }
        if self.state == .shouldResume {
            self.state = .playing
            // resume pad
            self.pad.play(from: self.pausedTime)
            // reset paused time
            self.pausedTime = 0.0
            // remove from queue
            self.queueToPlay.remove(self.pad)
            // call presenter
            self.presenter?.didResumeTrack()
        }
        if self.state == .playing {
            // increnemt bar
            self.currentBar += 1
            // call presenter for progress
            self.presenter?.willStartBar(
                with: self.currentBar,
                with: self.progress,
                withBar: self.barTime
            )
            if self.currentBar == self.totalBars {  // This schedule to play final chord after one bar
                self.playFinalAndTail(waitForNextBar: true)
            }
            if self.currentBar > self.totalBars {
                self.state = .shouldStop
            }
        }
        if self.state == .shouldStop {
            self.state = .stopped
            // stop pad
            self.pad.fadeOutAndStop(time: 0.1)
            // also stop all loops
            self.stopInstruments()
            // set current bar to max for progress
            self.currentBar = self.totalBars
            // call presenter to set progress 1.0
            self.presenter?.willStartBar(
                with: self.currentBar,
                with: self.progress,
                withBar: self.barTime
            )

            self.trackDidFinished()
        }

        // Queue to play
        self.queueToPlay.forEach { node in
            if let instrument = node as? AKPlayer {
                // instrument.audioFile!.fileNamePlusExtension is important
                self.presenter?.didStartInstrument(
                    with: instrument.audioFile!.fileNamePlusExtension,
                    diration: instrument.duration
                )
            }
        }
        self.queueToPlay.removeAll()

        // Queue to stop
        self.queueToStop.forEach { node in
            if let instrument = node as? AKPlayer {
                // instrument.audioFile!.fileNamePlusExtension is important
                self.presenter?.didStopInstrument(with: instrument.audioFile!.fileNamePlusExtension)
            }
        }
        self.queueToStop.removeAll()

    }

}

// MARK: Presenter -> Mixer

extension Mixer {

    func play() {

        // Play from paused time
        if self.state == .paused {
            self.state = .shouldResume
            self.queueToPlay.insert(self.pad)
            return
        }

        // Start from begining
        if self.state == .shouldStart {
            self.pad.play(at: self.audioTimeForNextBar())
            self.queueToPlay.insert(self.pad)
        }

        // when tail plays
        if self.state == .stopped {
            if self.tail.isPaused {
                self.tail.resume()
                self.presenter?.didStartPlayingTail()
            }
        }

    }

    func pause() {

        // for playing state
        if self.state == .playing {
            // set state
            self.state = .shouldPause
            // stop main pad
            self.queueToStop.insert(self.pad)
        }

        // when tail plays
        if self.state == .stopped {
            if self.tail.isPlaying {
                self.tail.fadeOutAndPause()
                self.presenter?.didPausePlayingTail()
            }
        }

    }

    func stop() {

        // if playing than stop on next bar
        if self.state == .playing {
            self.state = .shouldStop
            self.playFinalAndTail()
        }

        // if paused than stop immediately
        if self.state == .paused {
            self.state = .stopped

            // set current bar to max for progress
            self.currentBar = self.totalBars
            // call presenter to set progress 1.0
            self.presenter?.willStartBar(
                with: self.currentBar,
                with: self.progress,
                withBar: self.barTime
            )
            // play final chord and tail
            self.playFinalAndTail(shouldPlayNow: true)
        }

    }

    func finish() {
        self.deinitMixer()
    }

    /// Toggle instrument with fileName associated with button also pass bell filename
    /// onPlayjustBell is calling only in pause mode
    func toggleInstrument(with filename: String, bellFilename: String) {

        // disable to play loop on paused or stopped state
        if self.state == .paused || self.state == .stopped {

            // play bell
            self.playBell(with: bellFilename)

            self.presenter?.willStartInstrument(
                with: filename,
                after: 1.0
            )
            return
        }

        // $0.audioFile?.fileNamePlusExtension - is important
        guard let instrumentToEnqueue = self.allInstruments.first(where: { $0.audioFile?.fileNamePlusExtension == filename }) else {
            fatalError(">>> \(#file) - \(#function): Instrument with name \(filename) not found.")
        }
        self.toggleInstrument(instrument: instrumentToEnqueue, bellFilename: bellFilename)
    }

    func getCurrentAmplitude() {
        self.presenter?.onCurrentAmplitude(
            for: self.leadAmplitudeTracker.amplitude,
            for: self.bassAmplitudeTracker.amplitude
        )
    }

}

// MARK: Private methods

extension Mixer {

    private func toggleInstrument(instrument: AKPlayer, bellFilename: String? = nil) {

        // cancell queued instrument
        if self.queueToPlay.contains(instrument) {
            self.queueToPlay.remove(instrument)
            // stop scheduled instrument
            instrument.fadeOutAndStop(time: 0.1)
            self.presenter?.didCancelInstrument(with: instrument.audioFile!.fileNamePlusExtension)
            return
        }

        // stop playing instrument
        if instrument.isPlaying {
            // This use for pending animation. Potentialy shoud be removed or remaked
            // let nextBarAfter = self.timeBeforeNextBar()
            let nextBarAfter = 0.1
            self.presenter?.willStopInstrument(
                with: instrument.audioFile!.fileNamePlusExtension,
                after: nextBarAfter
            )
            // stop with 1/16 offset before next bar start
            DispatchQueue.main.asyncAfter(deadline: (.now() + self.stopTimeBeforeNextBar())) {
                instrument.fadeOutAndStop(time: 0.1)
            }
            self.queueToStop.insert(instrument)
            return
        }

        // stop sibling instrument
        if self.leadsInstruments.contains(instrument) {
            let instruments = self.leadsInstruments.filter({ $0.isPlaying })
            instruments.forEach { siblingInstrument in
                self.toggleInstrument(instrument: siblingInstrument)
            }
        }
        if self.bassInstruments.contains(instrument) {
            let instruments = self.bassInstruments.filter({ $0.isPlaying })
            instruments.forEach { siblingInstrument in
                self.toggleInstrument(instrument: siblingInstrument)
            }
        }

        // play bell
        self.playBell(with: bellFilename)

        // call presenter
        self.presenter?.willStartInstrument(
            with: instrument.audioFile!.fileNamePlusExtension,
            after: self.timeBeforeNextBar()
        )

        // schedule instrument to playing
        instrument.play(at: self.audioTimeForNextBar())

        // add to queue
        self.queueToPlay.insert(instrument)
    }

    private func stopInstruments() {
        let instrumentsToStop = self.allInstruments.filter { $0.isPlaying }
        instrumentsToStop.forEach { self.toggleInstrument(instrument: $0) }
    }

    private func playBell(with fileName: String?) {
        guard let fileName = fileName else { return }

        let allBells = self.leadBells + self.bassBells
        if let bellToPlay = allBells.first(where: { $0.audioFile?.fileNamePlusExtension == fileName }) {
            if !bellToPlay.isPlaying {
                bellToPlay.completionHandler = {  }
                bellToPlay.play(at: .now() + 0.05)
            }
        }
    }

    private func playFinalAndTail(shouldPlayNow: Bool = false, waitForNextBar: Bool = false) {

        if shouldPlayNow {
            // play final chords
            self.finalChord.play(at: .now()+0.05)   // was +0.05
            // start playing tail
            self.tail.play(at: .now()+0.05)         // was +0.05

            // notify presenter
            self.presenter?.didStartPlayingTail()

            return
        }

        if waitForNextBar {
            // play final chords
            self.finalChord.play(at: AVAudioTime.now()+self.barTime)
            
            // start playing tail
            self.tail.play(at: AVAudioTime.now()+self.barTime)

            // notify presenter
            DispatchQueue.main.asyncAfter(deadline: .now() + self.timeBeforeNextBar()) {
                self.presenter?.didStartPlayingTail()
            }

            return
        }

        // play final chords
        self.finalChord.play(at: self.audioTimeForNextBar())

        // start playing tail
        self.tail.play(at: self.audioTimeForNextBar())

        // notify presenter
        DispatchQueue.main.asyncAfter(deadline: .now() + self.timeBeforeNextBar()) {
            self.presenter?.didStartPlayingTail()
        }
    }

    /// Finalize track sience end bar is reached
    private func trackDidFinished() {
        self.presenter?.didFinishTrack()
    }

    private func deinitMixer() {

        self.tail.fadeOutFor1Second()

        // deinit mixer
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}

// MARK: - Reverb

extension Mixer {

    func getReverbPresetsList() -> [(Int, String)] {
        let presetsList: [AVAudioUnitReverbPreset] = [
            .smallRoom,
            .mediumRoom,
            .largeRoom,
            .mediumHall,
            .largeHall,
            .plate,
            .mediumChamber,
            .largeChamber,
            .cathedral,
            .largeRoom2,
            .mediumHall2,
            .mediumHall3,
            .largeHall2
        ]
        let presetsNames: [String] = [
            "smallRoom",
            "mediumRoom",
            "largeRoom",
            "mediumHall",
            "largeHall",
            "plate",
            "mediumChamber",
            "largeChamber",
            "cathedral",
            "largeRoom2",
            "mediumHall2",
            "mediumHall3",
            "largeHall2"
        ]


        return presetsList.map({ ($0.rawValue, presetsNames[$0.rawValue]) })
    }

    func getReverbCurrentDryWet() -> Double {
        return self.leadReverb.dryWetMix
    }

    func setReverbPreset(_ preset: Int) {
        let preset = AVAudioUnitReverbPreset(rawValue: preset)!
        self.leadReverb.loadFactoryPreset(preset)
        self.bassReverb.loadFactoryPreset(preset)
    }

    func setReverbDryWet(_ dryWet: Double) {
        self.leadReverb.dryWetMix = dryWet
        self.bassReverb.dryWetMix = dryWet
    }

}

// MARK: Utils

private extension Mixer {

    private func timeBeforeNextBar() -> Double {
        return self.timer?.fireDate.timeIntervalSinceNow ?? 1.0
    }

    private func audioTimeForNextBar() -> AVAudioTime {
        return AVAudioTime.now() + self.timeBeforeNextBar()
    }

    private func stopTimeBeforeNextBar() -> Double {
        return self.timeBeforeNextBar() - self.barTime / 10.0
    }

}
