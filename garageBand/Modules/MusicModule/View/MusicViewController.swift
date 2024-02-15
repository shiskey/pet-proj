//
//  MusicViewController.swift
//  garageBand
//
//  Created by mark on 31/01/2022.
//  Copyright © 2022 mark All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

enum LoopButtonPosition {
    case top, bottom
}

class MusicViewController: UIViewController, MusicViewProtocol {

    /*
     Some code removed
     */

}

// MARK: - Interruption handler

extension MusicViewController {

    @objc func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        if type == .began {
            // pause track
            self.presenter?.pauseTrack()
        }
        else if type == .ended {
            guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption Ended - playback should resume
                // not using for now
            }
        }
    }

    @objc func didResignActive() {
        self.scene?.isPaused = true
    }

    @objc func didBecomeActive() {
        self.scene?.isPaused = false
    }

}

// MARK: - ControlButtons delegate

extension MusicViewController: ControlButtonsDelegate {
    func controlButtonsTap(button: ControlButtons.Button, at state: ControlButtons.State) {

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        switch (button, state) {

        case (ControlButtons.Button.play, ControlButtons.State.pause):
            self.presenter?.startTrack()
        case (ControlButtons.Button.pause, ControlButtons.State.play):
            self.presenter?.pauseTrack()

        case (ControlButtons.Button.play, ControlButtons.State.tailPause):
            self.presenter?.resumeTail()
        case (ControlButtons.Button.pause, ControlButtons.State.tailPlay):
            self.presenter?.pauseTail()

        case (ControlButtons.Button.stop, _):
            self.presenter?.stopTrack()
            self.hideAllButtons()

        case (ControlButtons.Button.menu, _):
            self.presenter?.finishTrack()
            self.dismiss(animated: true, completion: nil)

        default:
            assertionFailure("Check this state")
        }
    }
}

// MARK: - CountdownTimerViewDelegate

extension MusicViewController: CountdownTimerViewDelegate {
    func countdownTimerDidEnd() {
        self.presenter?.finishTrack()
        self.dismiss(animated: true, completion: nil)
    }
}

// Mark: Presenter -> Self

extension MusicViewController {
    
    func showPlayControlButton() {
        self.controlButtons.state = .pause
    }
    
    func showPauseControlButton() {
        self.controlButtons.state = .play
    }
    
    func showTailPlayControlButton() {
        self.controlButtons.state = .tailPlay
    }

    func showTailPauseControlButton() {
        self.controlButtons.state = .tailPause
    }
    
    func blockControlButtons() {
        self.controlButtons.disableButtons()
    }
    
    func unblockControlButtons() {
        self.controlButtons.enableButtons()
    }
    
    func showWave(for leadInstruments: Double, for bassInstruments: Double) {
        self.scene?.showWave(for: leadInstruments, for: bassInstruments)
    }
    
    func showProgress(for progress: CGFloat, animation durations: Double) {
        self.scene?.showProgress(for: progress, animation: durations)
    }
    
    func showButtonFor(bar number: Int) {
        self.scene?.showButtonFor(bar: number)
    }
    
    func hideButtonFor(bar number: Int) {
        self.scene?.hideButtonFor(bar: number)
    }
    
    func startButtonPending(with name: String, duration: Double) {
        self.scene?.startButtonPending(with: name, duration: duration)
    }
    
    func cancelButtonPending(with name: String) {
        self.scene?.cancelButtonPending(with: name)
    }
    
    func activateButton(with name: String, progressDuration: Double) {
        self.scene?.activateButton(with: name, progressDuration: progressDuration)
    }
    
    func deactivateButton(with name: String) {
        self.scene?.deactivateButton(with: name)
    }
    
    func addToTimelineButton(with name: String) {
        self.scene?.addToTimelineButton(with: name)
    }

    func hideAllButtons() {
        self.scene?.throwawayButtons()
        self.scene?.hideTimeline()

        // deem screen
        UIView.animate(withDuration: 2.0, delay: 4.0, options: [], animations: {
            self.backgroundView.alpha = 0.65
        }, completion: nil)
    }

    func showCountdownTimerAndStart() {
        self.countdownTimerView.startCountdown()
        self.countdownTimerView.alpha = 0.0
        self.countdownTimerView.isHidden = false
        UIView.animate(withDuration: 2.0, delay: 4.0, options: [], animations: {
            self.countdownTimerView.alpha = 1.0
        }, completion: nil)
    }

}
