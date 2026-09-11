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

    /// Set to the message's file URL when a tap kicks off a fresh download, so that
    /// fileDownloadCompleted(_:) can open the file automatically once it lands instead
    /// of making the user tap the card a second time. Cleared on reuse and after it fires.
    private var pendingOpenFileUrl: String?

    // MARK: Caption layout
    //
    // The xib pins the file badge to the bubble's vertical centre and never links
    // the caption textView's bottom to the bubble, so a file sent *with* a caption
    // grows the textView outside the rounded bubble and the text is clipped. These
    // constraints are toggled on only when a caption is present: pin the bubble
    // bottom below the caption, and switch the badge from centre- to top-aligned so
    // a long caption doesn't leave a gap above the icon. Mirrors how the image cell
    // keeps its caption inside the bubble.

    /// The xib's `badge.centerY == bgView.centerY` constraint, found at runtime so it
    /// can be swapped out for `badgeTopConstraint` while a caption is showing. Held
    /// strongly - deactivating it removes it from its view, and a weak ref would let
    /// it deallocate so it could never be reactivated when the cell is reused.
    private var badgeCenterYConstraint: NSLayoutConstraint?

    private lazy var badgeTopConstraint: NSLayoutConstraint =
        docImageBadgeView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12)

    private lazy var bubbleBottomBelowCaptionConstraint: NSLayoutConstraint = {
        let c = bgView.bottomAnchor.constraint(greaterThanOrEqualTo: textView.bottomAnchor, constant: 10)
        c.priority = .required
        return c
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Badge is a fixed 44x44 in the xib - hardcoded radius avoids depending on bounds
        // being resolved by Auto Layout yet at awakeFromNib time. Full circle, half the
        // fixed size, matching the call icon badge.
        docImageBadgeView.layer.cornerRadius = 22
        docImageBadgeView.clipsToBounds = true
        docImageBadgeView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)

        badgeCenterYConstraint = bgView.constraints.first { c in
            (c.firstItem === docImageBadgeView && c.firstAttribute == .centerY && c.secondItem === bgView)
                || (c.secondItem === docImageBadgeView && c.secondAttribute == .centerY && c.firstItem === bgView)
        }
    }

    /// Grow the bubble to contain the caption (and move the badge to the top) when
    /// there is one; restore the centred, caption-free layout when there isn't.
    private func applyCaptionLayout(hasCaption: Bool) {
        badgeCenterYConstraint?.isActive = !hasCaption
        badgeTopConstraint.isActive = hasCaption
        bubbleBottomBelowCaptionConstraint.isActive = hasCaption
        setNeedsLayout()
    }

    override func setCellWith(message: HippoMessage, comingFrom: String) {
        super.setCellWith(message: message, comingFrom: comingFrom)

        // super already toggles constraintHeightTextView / sets textView.text off
        // `message.message != ""`; layer the "like the image cell" bits on top:
        // hide the textView entirely when blank, and give a real caption a trailing
        // newline so the time + tick that sit bottom-right don't collide with the
        // last line.
        let hasCaption = !message.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        textView.isHidden = !hasCaption
        if hasCaption {
            textView.text = "\(message.message)\n"
        } else {
            constraintHeightTextView.isActive = true
        }
        applyCaptionLayout(hasCaption: hasCaption)
    }

    override func intalizeCell(with message: HippoMessage, isIncomingView: Bool) {
        // Cell is being handed a (possibly different) message - drop any stale
        // "open when the download finishes" intent from the previous binding.
        pendingOpenFileUrl = nil
        super.intalizeCell(with: message, isIncomingView: isIncomingView)
    }

    override func fileDownloadCompleted(_ notification: Notification) {
        // super stops the spinner and unhides docImage via updateUIAccordingToFileDownloadStatus().
        super.fileDownloadCompleted(notification)

        guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String,
              url == pendingOpenFileUrl,
              let message = message,
              message.fileUrl == url,
              DownloadManager.shared.isFileDownloadedWith(url: url) else {
            return
        }
        // The download this cell's tap started has landed - open it now. Going back
        // through performActionAccordingToStatusOf keeps the "already downloaded ->
        // QuickLook" branch as the single place that opens files.
        pendingOpenFileUrl = nil
        actionDelegate?.performActionAccordingToStatusOf(message: message, inCell: self)
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
        // Caption sits on the accent bubble - same white-on-accent as the image
        // cell's caption (CustomerOutgoingImageCell.applyRevampColors). The xib
        // leaves it at the default label colour, which reads dark on the bubble.
        textView.textColor = colorConfig.hippoOnAccent
        textView.tintColor = colorConfig.hippoOnAccent
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
            // If the file isn't cached yet this tap starts a download - remember to
            // auto-open it when fileDownloadCompleted(_:) fires. If it's already
            // downloaded, performActionAccordingToStatusOf opens it right here.
            if let fileUrl = message.fileUrl,
               !DownloadManager.shared.isFileDownloadedWith(url: fileUrl) {
                pendingOpenFileUrl = fileUrl
            }
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
