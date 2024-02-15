//
//  MusicPresenter.swift
//  garageBand
//
//  Created by mark on 13/02/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit

class MusicPresenter: MusicPresenterProtocol {
    var wireFrame: MusicWireframeProtocol?
    weak var view: MusicViewProtocol?
    weak var mixer: MusicMixerProtocol?
}

// MARK: Common methods related

extension MusicPresenter {
    func getReverbPresetsList() -> [(Int, String)] {
        return self.mixer!.getReverbPresetsList()
    }
    func getReverbCurrentDryWet() -> Double {
        return self.mixer!.getReverbCurrentDryWet()
    }
    func setReverbPreset(_ preset: Int) {
        self.mixer?.setReverbPreset(preset)
    }
    func setReverbDryWet(_ dryWet: Double) {
        self.mixer?.setReverbDryWet(dryWet)
    }
}

// MARK: View related

extension MusicPresenter {
    
    func viewDidLoad() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startTrack()
        }
    }
    
    func updateFrame() {
        self.mixer?.getCurrentAmplitude()
    }
    
    func onTapButton(with name: String, bellFilename: String) {
        self.mixer?.toggleInstrument(with: name, bellFilename: bellFilename)
    }
    
    func startTrack() {
        self.view?.blockControlButtons()
        self.view?.showPauseControlButton()
        self.mixer?.play()
    }
    
    func pauseTrack() {
        self.view?.blockControlButtons()
        self.view?.showPlayControlButton()
        self.mixer?.pause()
    }
    
    func stopTrack() {
        self.view?.showTailPlayControlButton()
        self.mixer?.stop()
    }

    func finishTrack() {
        self.mixer?.finish()
    }

    func pauseTail() {
        self.mixer?.pause()
    }

    func resumeTail() {
        self.mixer?.play()
    }

}

// MARK: Mixer related

extension MusicPresenter {
    
    func didStartTrack() {
        self.view?.unblockControlButtons()
    }
    
    func didPauseTrack() {
        self.view?.unblockControlButtons()
    }
    
    func didResumeTrack() {
        self.view?.unblockControlButtons()
    }
    
    func didFinishTrack() {
        self.view?.hideAllButtons()
        self.view?.showCountdownTimerAndStart()
    }

    func didStartPlayingTail() {
        self.view?.showTailPlayControlButton()
    }

    func didPausePlayingTail() {
        self.view?.showTailPauseControlButton()
    }

    func onCurrentAmplitude(for leadInstruments: Double, for bassInstruments: Double) {
        self.view?.showWave(for: leadInstruments, for: bassInstruments)
    }
    
    func willStartBar(with number: Int, with progress: CGFloat, withBar duration: Double) {
        self.view?.showButtonFor(bar: number)
        self.view?.hideButtonFor(bar: number)
        self.view?.showProgress(for: progress, animation: duration)
    }
    
    func willStartInstrument(with fileName: String, after duration: Double) {
        self.view?.startButtonPending(with: fileName, duration: duration)
    }
    
    func willStopInstrument(with fileName: String, after duration: Double) {
        self.view?.deactivateButton(with: fileName)
    }
    
    func didCancelInstrument(with fileName: String) {
        self.view?.cancelButtonPending(with: fileName)
    }
    
    func didStartInstrument(with name: String, diration: Double) {
        self.view?.activateButton(with: name, progressDuration: diration)
        self.view?.addToTimelineButton(with: name)
    }
    
    func didStopInstrument(with name: String) {
        // Do nothing
    }

}
