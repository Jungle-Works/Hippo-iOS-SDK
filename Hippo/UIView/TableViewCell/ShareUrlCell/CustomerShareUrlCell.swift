//
//  CustomerShareUrlCell.swift
//  Hippo
//
//  Customer-only variant of OutgoingShareUrlCell (the meeting/call-link card). The same
//  class backs both directions — isIncomingView (set by intalizeCell) tells us which side
//  we're on. Rounds all four corners to match the other revamped cards and hides the
//  avatar on the incoming side (outgoing never wires one up, so hiding is a no-op there).
//

import UIKit

class CustomerShareUrlCell: OutgoingShareUrlCell {

    override func layoutSubviews() {
        super.layoutSubviews()
        // Deferred a run-loop turn on purpose — same reason as the other revamped cells:
        // CAShapeLayer.path is a one-shot bounds snapshot, and this card's height can take
        // more than one Auto Layout pass to settle.
        //
        // resetPropertiesOfOutgoingCell(isIncoming:) re-applies its own uniform
        // cornerRadius/maskedCorners to mainContentView and shadowView on every configure —
        // zero it and mask both directly, same fix as the image cells.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mainContentView.layer.cornerRadius = 0
            self.mainContentView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 10)
            self.shadowView.layer.cornerRadius = 0
            self.shadowView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 10)
        }
    }

    override func setSenderImageView() {
        // No profile icon on the meeting-link card in the revamped customer thread.
        // OutgoingShareUrlCell.xib never wires up senderImageView at all, so this is a
        // no-op there — only the incoming xib actually has an avatar to hide.
        hideSenderImageView()
    }
}
