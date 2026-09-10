//
//  CustomerIncomingImageCell.swift
//  Hippo
//
//  Customer-only variant of IncomingImageCell. Equal top/left/right padding around the
//  thumbnail and a slightly taller bottom gap. Timestamp position and styling are
//  untouched from the legacy cell — below the photo, in their original place.
//

import UIKit

class CustomerIncomingImageCell: IncomingImageCell {

    // Forces the (rarely-shown) caption textView to zero height when there's no caption —
    // without this, an empty UITextView still reports its font's line-height as intrinsic
    // content size, silently padding the bubble's bottom.
    @IBOutlet weak var captionHeightConstraint: NSLayoutConstraint!

    override func intalizeCell(with message: HippoMessage, isIncomingView: Bool) {
        super.intalizeCell(with: message, isIncomingView: isIncomingView)
        // configureIncomingCell() calls this, then setupBoxBackground() (legacy grey)
        // AFTER it, with no guaranteed layout pass on an async re-config — so the
        // receiver card/border only appeared after a scroll forced layoutSubviews.
        // Schedule that pass now.
        setNeedsLayout()
    }

    // `setTime()` runs near the end of configureIncomingCell(), after
    // setupBoxBackground()'s legacy grey — re-assert the receiver palette there so
    // it lands immediately instead of only after a scroll.
    override func setTime() {
        super.setTime()
        applyRevampColors()
    }

    private func applyRevampColors() {
        let colorConfig = HippoConfig.shared.colorConfig
        mainContentView.backgroundColor = colorConfig.hippoReceiver
        shadowView.backgroundColor = colorConfig.hippoBorder
        textView.textColor = colorConfig.hippoTextPrimary
        timeLabel.textColor = colorConfig.hippoTextMuted
    }

    override func layoutSubviews() {
        // configureIncomingCell(...) is declared in a class extension on IncomingImageCell,
        // so it uses static dispatch and can't be overridden here — toggle the caption
        // height constraint from layoutSubviews instead, which runs after every configure.
        captionHeightConstraint?.isActive = textView.isHidden
        super.layoutSubviews()
        // Deferred a run-loop turn on purpose — same reason as the other revamped cells:
        // CAShapeLayer.path is a one-shot bounds snapshot, and this card's height can take
        // more than one Auto Layout pass to settle.
        //
        // resetPropertiesOfIncomingCell() (a non-overridable extension method on the base
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

        // Belt-and-braces: re-assert the palette after every layout pass too
        // (scroll/reuse, and the deferred adjustShadow() from super).
        applyRevampColors()
    }

    override func setSenderImageView() {
        // No profile icon on incoming image cards in the revamped customer thread —
        // collapses the leading space so the card aligns to the left.
        hideSenderImageView()
    }
}
