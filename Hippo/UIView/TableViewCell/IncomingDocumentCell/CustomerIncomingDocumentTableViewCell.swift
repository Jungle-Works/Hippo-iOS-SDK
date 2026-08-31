//
//  CustomerIncomingDocumentTableViewCell.swift
//  Hippo
//
//  Customer-only variant of IncomingDocumentTableViewCell. The revamped file card
//  (bigger badge-backed icon, file size/type aligned under the filename, no download
//  button) is unconditional here since this class is only ever dequeued for the
//  customer app.
//

import UIKit

class CustomerIncomingDocumentTableViewCell: IncomingDocumentTableViewCell {

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

        // activityIndicator is centred on docImageBadgeView, directly over docImage — hide the
        // file icon while the spinner is running so the two don't render on top of each other,
        // and bring it back once the download finishes (or hasn't started yet).
        if let fileUrl = message?.fileUrl {
            docImage.isHidden = DownloadManager.shared.isFileBeingDownloadedWith(url: fileUrl)
        }
    }

    override func setUIAccordingToTheme() {
        super.setUIAccordingToTheme()
        // Corner shape applied in layoutSubviews via applyCornerRadii — mixed per-corner
        // radii can't be expressed with cornerRadius alone. Same 10/10/5/10 as the text
        // bubble and call card.
        bgView.layer.cornerRadius = 0
        bgView.layer.borderWidth = 0

        // Received card reads the receiver/icon-secondary tokens instead of the legacy
        // pale-blue recievingBubbleColor — matching the received text bubble.
        let colorConfig = HippoConfig.shared.colorConfig
        bgView.backgroundColor = colorConfig.hippoReceiver
        docImageBadgeView.backgroundColor = colorConfig.hippoIconSecondarySurface
        docImage.tintColor = colorConfig.hippoIconSecondary
        docName.textColor = colorConfig.hippoTextPrimary
        fileSizeLabel.textColor = colorConfig.hippoTextMuted
        nameLabel.textColor = colorConfig.hippoTextMuted
        activityIndicator.tintColor = colorConfig.hippoTextMuted
        activityIndicator.color = colorConfig.hippoTextMuted
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Deferred a run-loop turn on purpose — same reason as the message bubbles:
        // CAShapeLayer.path is a one-shot bounds snapshot, and this card's height can take
        // more than one Auto Layout pass to settle.
        DispatchQueue.main.async { [weak self] in
            self?.bgView.applyCornerRadii(topLeft: 10, topRight: 10, bottomLeft: 5, bottomRight: 10)
        }
    }

    override func setSenderImageView() {
        // No profile icon on incoming file cards in the revamped customer thread —
        // collapses the leading space so the card aligns to the left.
        hideSenderImageView()
    }
}
