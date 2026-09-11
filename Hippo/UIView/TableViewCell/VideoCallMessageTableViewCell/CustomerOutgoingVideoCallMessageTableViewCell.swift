//
//  CustomerOutgoingVideoCallMessageTableViewCell.swift
//  Hippo
//
//  Customer-only variant of OutgoingVideoCallMessageTableViewCell. The revamped call card
//  (bigger badge-backed icon, duration/time sized relative to the message text) is
//  unconditional here since this class is only ever dequeued for the customer app.
//

import UIKit

class CustomerOutgoingVideoCallMessageTableViewCell: OutgoingVideoCallMessageTableViewCell {

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
            self?.messageBackgroundView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 5)
        }
    }

    override func setCellWith(message: HippoMessage, otherUserName: String, isCallingEnabled: Bool) {
        super.setCellWith(message: message, otherUserName: otherUserName, isCallingEnabled: isCallingEnabled)

        // Sender's own "You" identity row is redundant in the revamped customer thread, same
        // as every other self-sent cell.
        nameView.isHidden = true
        nameLbl.isHidden = true

        // phoneIcon.image is loaded plain (no .alwaysTemplate) by the base class, so a raster
        // asset with its own baked-in colour ignores tintColor entirely — force template mode
        // so the icon-pair tokens below actually reach the glyph.
        phoneIcon.image = phoneIcon.image?.withRenderingMode(.alwaysTemplate)

        let colorConfig = HippoConfig.shared.colorConfig
        messageBackgroundView.backgroundColor = colorConfig.hippoAccentSubtle2

        // Card fill always reads the accent-family ladder; only the badge/icon switch to
        // the missed pair, since a missed call reads as missed on both sides regardless of
        // which side's card it sits on.
        if message.isMissedCall {
            phoneIconBadgeView.backgroundColor = colorConfig.hippoCallIconMissedSurface
            phoneIcon.tintColor = colorConfig.hippoCallIconMissed
        } else {
            phoneIconBadgeView.backgroundColor = colorConfig.hippoCallIconPrimarySurface
            phoneIcon.tintColor = colorConfig.hippoCallIconPrimary
        }
        messageLabel.textColor = colorConfig.hippoTextPrimary
        callAgainButton.setTitleColor(colorConfig.hippoAccent, for: .normal)
        centerLineView.backgroundColor = colorConfig.hippoBorder
    }
}
