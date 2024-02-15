//
//  MusicProtocols.swift
//  garageBand
//
//  Created by mark on 14/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

protocol MusicWireframeProtocol: AnyObject {
    static func createMusicModuleWith(trackBundle: TrackBundle) -> UIViewController
}

// MARK: - Mixer

protocol MusicMixerProtocol: AnyObject {
    var presenter: MusicPresenterProtocol? { get set }
    init(trackBundle: TrackBundle)
    func play()
    func pause()
    func stop()
    func finish()
    func toggleInstrument(with filename: String, bellFilename: String)
    func getCurrentAmplitude()

    // TODO: REMOVE REVERB
    func getReverbPresetsList() -> [(Int, String)]
    func getReverbCurrentDryWet() -> Double
    func setReverbPreset(_ preset: Int)
    func setReverbDryWet(_ dryWet: Double)
    
}

// MARK: - View

protocol MusicViewProtocol: AnyObject {
    var presenter: MusicPresenterProtocol? { get set }
    var trackBundle: TrackBundle? { get set }
    func showPlayControlButton()
    func showPauseControlButton()
    func showTailPlayControlButton()
    func showTailPauseControlButton()
    func blockControlButtons()
    func unblockControlButtons()
    func showWave(for leadInstruments: Double, for bassInstruments: Double)
    func showProgress(for progress: CGFloat, animation durations: Double)
    func showButtonFor(bar number: Int)
    func hideButtonFor(bar number: Int)
    func startButtonPending(with name: String, duration: Double)
    func cancelButtonPending(with name: String)
    func activateButton(with name: String, progressDuration: Double)
    func deactivateButton(with name: String)
    func addToTimelineButton(with name: String)
    func hideAllButtons()
    func showCountdownTimerAndStart()
}

// MARK: - Presenter

protocol MusicPresenterProtocol: AnyObject {
    // Wireframe related
    var wireFrame: MusicWireframeProtocol? { get set }
    // View related
    var view: MusicViewProtocol? { get set }
    func viewDidLoad()
    func updateFrame()
    func onTapButton(with name: String, bellFilename: String)
    func startTrack()
    func pauseTrack()
    func stopTrack()
    func finishTrack()
    func pauseTail()
    func resumeTail()
    // Mixer related
    var mixer: MusicMixerProtocol? { get set }
    func didStartTrack()
    func didPauseTrack()
    func didResumeTrack()
    func didFinishTrack()
    func didStartPlayingTail()
    func didPausePlayingTail()
    func onCurrentAmplitude(for leadInstruments: Double, for bassInstruments: Double)
    func willStartBar(with number: Int, with progress: CGFloat, withBar duration: Double)
    func willStartInstrument(with fileName: String, after duration: Double)
    func willStopInstrument(with fileName: String, after duration: Double)
    func didCancelInstrument(with fileName: String)
    func didStartInstrument(with fileName: String, diration: Double)
    func didStopInstrument(with fileName: String)

    // TODO: REMOVE REVERB
    func getReverbPresetsList() -> [(Int, String)]
    func getReverbCurrentDryWet() -> Double
    func setReverbPreset(_ preset: Int)
    func setReverbDryWet(_ dryWet: Double)
    
}
