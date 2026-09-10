//
//  CustomerOutgoingImageCell.swift
//  Hippo
//
//  Customer-only variant of OutgoingImageCell. Equal top/left/right padding around the
//  thumbnail and a slightly taller bottom gap. Timestamp/read-tick position and styling
//  are untouched from the legacy cell — below the photo, in their original place.
//

import UIKit

class CustomerOutgoingImageCell: OutgoingImageCell {

    // `setTime()` is a real (overridable) `MessageTableViewCell` method that
    // `configureCellOfOutGoingImageCell()` calls near its end — crucially AFTER
    // `setupBoxBackground()` has repainted the legacy grey. Re-applying the accent
    // palette here means it lands on every (re)configure without waiting for a
    // layout pass, which is why the card used to stay grey until a scroll.
    override func setTime() {
        super.setTime()
        applyRevampColors()
    }

    private func applyRevampColors() {
        let colorConfig = HippoConfig.shared.colorConfig
        mainContentView.backgroundColor = colorConfig.hippoAccent
        shadowView.backgroundColor = colorConfig.hippoAccent
        textView.textColor = colorConfig.hippoOnAccent
        timeLabel.textColor = colorConfig.hippoOnAccent
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Deferred a run-loop turn on purpose — same reason as the other revamped cells:
        // CAShapeLayer.path is a one-shot bounds snapshot, and this card's height can take
        // more than one Auto Layout pass to settle.
        //
        // resetPropertiesOfOutgoingCell() (a non-overridable extension method on the base
        // class) re-applies its own uniform cornerRadius/maskedCorners to thumbnailImageView
        // AND shadowView on every configure. shadowView sits behind mainContentView, offset
        // 0.5pt larger on every edge for a border look — its un-rounded (partial) corner was
        // what actually showed through as a sharp point, since masking the front layers alone
        // doesn't hide what's peeking out from the layer behind them. Zero native corner
        // radius and mask all three views directly.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mainContentView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 10)
            self.thumbnailImageView.layer.cornerRadius = 0
            self.thumbnailImageView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 10)
            self.shadowView.layer.cornerRadius = 0
            self.shadowView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 10)
        }

        // Belt-and-braces: also re-assert the palette after every layout pass
        // (covers scroll/reuse and the deferred adjustShadow() from super).
        applyRevampColors()
    }
}
