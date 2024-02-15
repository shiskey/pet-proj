//
//  CountdownTimerView.swift
//  garageBand
//
//  Created by  mark on 27.07.2021.
//  Copyright © 2021 mark All rights reserved.
//

import UIKit

protocol CountdownTimerViewDelegate {
    func countdownTimerDidEnd()
}

class CountdownTimerView: UIView {

    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var minusButton: UIButton!
    @IBOutlet private var plusButton: UIButton!

    var delegate: CountdownTimerViewDelegate?

    private var secondsRemaining = 60*5+4     // 5 min by default + 4 sec. animation delay
    private var timer: Timer?

    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
}

// MARK: - Actions

extension CountdownTimerView {

    @IBAction
    func minusButtonAction() {
        if self.secondsRemaining > 60 { self.secondsRemaining -= 60 }
        else if self.secondsRemaining <= 60 && self.secondsRemaining > 10 { self.secondsRemaining -= 10 }
        else { self.secondsRemaining -= 1 }
        self.timeLabel.text = self.secondsRemaining.toTimeString
    }

    @IBAction
    func plusButtonAction() {
        self.secondsRemaining += 60
        self.timeLabel.text = self.secondsRemaining.toTimeString
    }

    func startCountdown() {

        // show initial time
        self.timeLabel.text = self.secondsRemaining.toTimeString

        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [unowned self] timer in

            if self.secondsRemaining > 0 {
                self.secondsRemaining -= 1
                self.timeLabel.text = self.secondsRemaining.toTimeString
            } else {
                timer.invalidate()
                self.delegate?.countdownTimerDidEnd()
            }
        }
    }
}

// MARK: - Utils

private extension Int {

    var toTimeString: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
        formatter.allowedUnits = [ .minute, .second ] // Units to display in the formatted string
        formatter.zeroFormattingBehavior = [ .pad ] // Pad with zeroes where appropriate for the locale
        return formatter.string(from: TimeInterval(self)) ?? "\(self)"
    }
}
