//
//  CustomerSupportMessageTableViewCell.swift
//  Hippo
//
//  Customer-only variant of SupportMessageTableViewCell. The revamped
//  bubble look (per-corner radii, tighter padding, no sender-name row, no
//  avatar) is unconditional here since this class is only ever dequeued
//  for the customer app — no appUserType branching needed inside it.
//

import UIKit

class CustomerSupportMessageTableViewCell: SupportMessageTableViewCell {

    override func layoutSubviews() {
        super.layoutSubviews()
        // See CustomerSelfMessageTableViewCell for why this is deferred a
        // run-loop turn: CAShapeLayer.path is a one-shot bounds snapshot,
        // and a self-sizing bubble's width can take more than one Auto
        // Layout pass to converge.
        DispatchQueue.main.async { [weak self] in
            self?.bgView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 5, bottomRight: 10)
        }
    }

    override func resetPropertiesOfSupportCell() {
        super.resetPropertiesOfSupportCell()
        // Corner shape applied in layoutSubviews via applyCornerRadii, once
        // bgView.bounds is final — mixed per-corner radii can't be
        // expressed with cornerRadius + maskedCorners alone.
        bgView.layer.cornerRadius = 0
        if #available(iOS 11.0, *) {
            bgView.layer.maskedCorners = []
        }

        timeLabel.textColor = HippoConfig.shared.colorConfig.hippoTextMuted
    }

    override func setupBoxBackground(messageType: MessageType) {
        // Received bubble reads the receiver token, not the legacy pale-blue
        // recievingBubbleColor — matching the Android revamp's "received bubble =
        // hippoReceiver" default. Private notes keep the legacy look untouched.
        guard messageType != .privateNote else {
            super.setupBoxBackground(messageType: messageType)
            return
        }
        bgView.backgroundColor = HippoConfig.shared.colorConfig.hippoReceiver
    }

    override func setSenderImageView() {
        // No avatar on received rows in the revamped customer thread.
        hideSenderImageView()
    }

    override func configureCellOfSupportIncomingCell(resetProperties: Bool, attributedString: NSMutableAttributedString, channelId: Int, chatMessageObject: HippoMessage) -> SupportMessageTableViewCell {
        let cell = super.configureCellOfSupportIncomingCell(resetProperties: resetProperties, attributedString: attributedString, channelId: channelId, chatMessageObject: chatMessageObject)

        // "X deleted this message" reads as a system note, not real message content —
        // italicise it, matching common chat-app convention. The base text comes from
        // MessageUIAttributes as a plain attributed string (font baked in per-run already),
        // so re-apply an italic variant of whatever font each run already has rather than
        // touching the shared model used by both agent and customer screens.
        guard chatMessageObject.messageState == .MessageDeleted,
              let text = supportMessageTextView.attributedText, text.length > 0 else {
            return cell
        }
        let italicText = NSMutableAttributedString(attributedString: text)
        let fullRange = NSRange(location: 0, length: italicText.length)
        italicText.enumerateAttribute(.font, in: fullRange, options: []) { value, subrange, _ in
            let baseFont = (value as? UIFont) ?? HippoConfig.shared.theme.incomingMsgFont
            italicText.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: baseFont.pointSize), range: subrange)
        }
        supportMessageTextView.attributedText = italicText
        return cell
    }
}
