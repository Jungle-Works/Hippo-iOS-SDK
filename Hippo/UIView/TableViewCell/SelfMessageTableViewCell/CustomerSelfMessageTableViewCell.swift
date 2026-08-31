//
//  CustomerSelfMessageTableViewCell.swift
//  Hippo
//
//  Customer-only variant of SelfMessageTableViewCell. The revamped bubble
//  look (per-corner radii, tighter padding, no "You" identity row) is
//  unconditional here since this class is only ever dequeued for the
//  customer app — no appUserType branching needed inside it.
//

import UIKit

class CustomerSelfMessageTableViewCell: SelfMessageTableViewCell {

    override func layoutSubviews() {
        super.layoutSubviews()
        // Deferred a run-loop turn on purpose. CAShapeLayer.path is a
        // one-shot snapshot of bgView.bounds — unlike cornerRadius +
        // maskedCorners, which CoreAnimation re-applies live against
        // whatever bounds are current at render time. A self-sizing
        // bubble's width can take more than one Auto Layout pass to
        // converge, and layoutSubviews can fire mid-convergence; snapshotting
        // then bakes in a too-narrow mask that clips the message text until
        // the next full layout pass (e.g. scrolling) recomputes it. By the
        // next run-loop turn, Auto Layout has necessarily finished
        // converging — nothing reaches the screen otherwise — so bounds
        // read there are the true final ones.
        DispatchQueue.main.async { [weak self] in
            self?.bgView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 5)
        }
    }

    override func resetPropertiesOfOutgoingMessage() {
        super.resetPropertiesOfOutgoingMessage()
        // Corner shape applied in layoutSubviews via applyCornerRadii, once
        // bgView.bounds is final — mixed per-corner radii can't be
        // expressed with cornerRadius + maskedCorners alone.
        bgView.layer.cornerRadius = 0
        if #available(iOS 11.0, *) {
            bgView.layer.maskedCorners = []
        }

        // Sent bubble reads the accent token, not the legacy grey chat-box colour —
        // matching the Android revamp's "sent bubble = hippoAccent" default. No border on
        // an accent-filled bubble.
        applyAccentColors()
    }

    override func setupBoxBackground(messageType: MessageType) {
        // configureIncomingMessageCell() calls this unconditionally, AFTER
        // resetPropertiesOfOutgoingMessage() — left un-overridden it stomps the accent
        // background straight back to the legacy outgoingChatBoxColor on every render.
        guard messageType != .privateNote else {
            super.setupBoxBackground(messageType: messageType)
            return
        }
        applyAccentColors()
    }

    private func applyAccentColors() {
        let colorConfig = HippoConfig.shared.colorConfig
        bgView.backgroundColor = colorConfig.hippoAccent
        bgView.layer.borderWidth = 0
        // Sent bubble always carries white body text + timestamp, regardless of the
        // accent's luminance — matches the design's fixed light-on-accent treatment.
        selfMessageTextView.textColor = .white
        timeLabel.textColor = .white

        // "You deleted this message" reads as a system note, not real message content —
        // italicise it, matching common chat-app convention.
        let baseFont = HippoConfig.shared.theme.inOutChatTextFont
        selfMessageTextView.font = message?.messageState == .MessageDeleted
            ? UIFont.italicSystemFont(ofSize: baseFont.pointSize)
            : baseFont
    }
}
