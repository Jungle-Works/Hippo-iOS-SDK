//
//  CustomerIncomingVideoCallMessageTableViewCell.swift
//  Hippo
//
//  Customer-only variant of IncomingVideoCallMessageTableViewCell. The revamped call card
//  (bigger badge-backed icon, duration/time sized relative to the message text) is
//  unconditional here since this class is only ever dequeued for the customer app.
//

import UIKit

class CustomerIncomingVideoCallMessageTableViewCell: IncomingVideoCallMessageTableViewCell {

    @IBOutlet weak var phoneIconBadgeView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Badge is a fixed 40x40 in the xib - hardcoded radius avoids depending on bounds
        // being resolved by Auto Layout yet at awakeFromNib time.
        phoneIconBadgeView.layer.cornerRadius = 20
        phoneIconBadgeView.clipsToBounds = true
        // Duration/time read a couple points smaller than the call message itself, same
        // family/weight as the message so they still read as one related block.
        let smallerSize = max(messageLabel.font.pointSize - 2, 10)
        let smallerFont = UIFont(descriptor: messageLabel.font.fontDescriptor, size: smallerSize)
        callDurationLabel.font = smallerFont
        dateTimeLabel.font = smallerFont

        // Corner shape applied in layoutSubviews via applyCornerRadii, matching the text
        // bubble's mixed per-corner radii, which cornerRadius + maskedCorners alone can't
        // express.
        messageBackgroundView.layer.cornerRadius = 0
        if #available(iOS 11.0, *) {
            messageBackgroundView.layer.maskedCorners = []
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Deferred a run-loop turn on purpose — same reason as the message bubbles:
        // CAShapeLayer.path is a one-shot bounds snapshot, and this card's height can take
        // more than one Auto Layout pass to settle.
        DispatchQueue.main.async { [weak self] in
            self?.messageBackgroundView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 5, bottomRight: 10)
        }
    }

    override func setCellWith(message: HippoMessage, isCallingEnabled: Bool) {
        super.setCellWith(message: message, isCallingEnabled: isCallingEnabled)

        // Video calls get the video glyphs (the base class always loads the voice set,
        // which the agent screen keeps). Template-rendered so the icon-pair tokens below
        // reach the glyph rather than the asset's baked-in colour.
        phoneIcon.image = message.callIcon(message.isMissedCall ? .missed : .incoming)

        let colorConfig = HippoConfig.shared.colorConfig
        messageBackgroundView.backgroundColor = colorConfig.hippoReceiverSubtle2

        // Card fill always reads the receiver-family ladder; only the badge/icon switch to
        // the missed pair, since a missed call reads as missed on both sides regardless of
        // which side's card it sits on.
        if message.isMissedCall {
            phoneIconBadgeView.backgroundColor = colorConfig.hippoCallIconMissedSurface
            phoneIcon.tintColor = colorConfig.hippoCallIconMissed
        } else {
            phoneIconBadgeView.backgroundColor = colorConfig.hippoCallIconSecondarySurface
            phoneIcon.tintColor = colorConfig.hippoCallIconSecondary
        }
        messageLabel.textColor = colorConfig.hippoTextPrimary
        callAgainButton.setTitleColor(colorConfig.hippoAccent, for: .normal)
    }

    override func setSenderImageView() {
        // No profile icon on incoming call cards in the revamped customer thread.
        hideSenderImageView()
    }
}
