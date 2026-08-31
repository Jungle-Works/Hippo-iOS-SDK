//
//  CustomerOutgoingDocumentTableViewCell.swift
//  Hippo
//
//  Customer-only variant of OutgoingDocumentTableViewCell. The revamped file card
//  (bigger badge-backed icon, file size/type aligned under the filename, no download
//  button) is unconditional here since this class is only ever dequeued for the
//  customer app.
//

import UIKit

class CustomerOutgoingDocumentTableViewCell: OutgoingDocumentTableViewCell {

    @IBOutlet weak var docImageBadgeView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Badge is a fixed 44x44 in the xib - hardcoded radius avoids depending on bounds
        // being resolved by Auto Layout yet at awakeFromNib time. Full circle, half the
        // fixed size, matching the call icon badge.
        docImageBadgeView.layer.cornerRadius = 22
        docImageBadgeView.clipsToBounds = true
        docImageBadgeView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }

    override func updateUIAccordingToFileDownloadStatus() {
        super.updateUIAccordingToFileDownloadStatus()
        // The whole card is already tap-to-download via bgViewTaped(); no separate
        // button needed on the customer screen.
        retryButton.isHidden = true
    }

    override func setUIAccordingToTheme() {
        super.setUIAccordingToTheme()
        // Corner shape applied in layoutSubviews via applyCornerRadii — mixed per-corner
        // radii can't be expressed with cornerRadius alone. Same 10/10/10/5 as the text
        // bubble and call card.
        bgView.layer.cornerRadius = 0
        bgView.layer.borderWidth = 0

        // Sent card reads the accent/icon-primary tokens instead of the legacy grey —
        // matching the sent text bubble.
        let colorConfig = HippoConfig.shared.colorConfig
        bgView.backgroundColor = colorConfig.hippoAccent
        docImageBadgeView.backgroundColor = colorConfig.hippoIconPrimarySurface
        docImage.tintColor = colorConfig.hippoIconPrimary
        docName.textColor = colorConfig.hippoOnAccent
        fileSizeLabel.textColor = colorConfig.hippoOnAccent
        nameLabel.textColor = colorConfig.hippoOnAccent
        activityIndicator.tintColor = colorConfig.hippoOnAccent
        activityIndicator.color = colorConfig.hippoOnAccent
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Deferred a run-loop turn on purpose — same reason as the message bubbles:
        // CAShapeLayer.path is a one-shot bounds snapshot, and this card's height can take
        // more than one Auto Layout pass to settle.
        DispatchQueue.main.async { [weak self] in
            self?.bgView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 5)
        }
    }

    override func bgViewTaped() {
        // OutgoingDocumentTableViewCell.bgViewTaped() gates the whole tap behind
        // !retryButton.isHidden — but updateUIAccordingToFileDownloadStatus() above always
        // hides retryButton on this screen (the whole card is meant to be tap-to-act
        // instead), so calling super here silently no-ops and the card never downloads or
        // opens. Reimplement without that guard: retry an unsent upload, otherwise
        // download/open exactly like the shared DocumentTableViewCell.bgViewTaped() would.
        guard let message = message else { return }
        switch message.status {
        case .none:
            delegate?.retryUploadFor(message: message)
        default:
            actionDelegate?.performActionAccordingToStatusOf(message: message, inCell: self)
            updateUI()
        }
        if message.senderFullName ?? "" != HippoConfig.shared.agentDetail?.fullName ?? "" {
            setCellWith(message: message, comingFrom: message.senderFullName ?? "")
        } else {
            setCellWith(message: message, comingFrom: "You")
        }
    }
}
