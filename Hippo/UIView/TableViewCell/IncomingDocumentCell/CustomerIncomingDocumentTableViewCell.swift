//
//  CustomerIncomingDocumentTableViewCell.swift
//  Hippo
//
//  Customer-only variant of IncomingDocumentTableViewCell. The revamped file card
//  (bigger badge-backed icon, file size/type aligned under the filename, download
//  states drawn in the badge - see CustomerDocumentDownloadCapable) is unconditional
//  here since this class is only ever dequeued for the customer app.
//

import UIKit

class CustomerIncomingDocumentTableViewCell: IncomingDocumentTableViewCell, CustomerDocumentDownloadCapable {

    @IBOutlet weak var docImageBadgeView: UIView!

    var pendingOpenFileUrl: String?
    var progressRing: DownloadProgressRingView?
    var isDownloadStateApplicable: Bool { true }
    private var containerTapAdded = false

    // MARK: Caption layout
    //
    // The xib pins the file badge to the bubble's vertical centre and never links
    // the caption textView's bottom to the bubble, so a file received *with* a
    // caption grows the textView outside the rounded bubble and the text is
    // clipped. Toggled on only when a caption is present: pin the bubble bottom
    // below the caption, and switch the badge from centre- to top-aligned so a
    // long caption doesn't leave a gap above the icon. Same as the sent doc cell.

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
        installProgressRing()
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadProgressed(_:)), name: .fileDownloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadFailed(_:)), name: .fileDownloadFailed, object: nil)
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

    override func setCellWith(message: HippoMessage) {
        super.setCellWith(message: message)

        // super already toggles constraintHeightTextView / sets textView.text off
        // `message.message != ""`; layer the "like the image cell" bits on top.
        let hasCaption = !message.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        textView.isHidden = !hasCaption
        if hasCaption {
            textView.text = "\(message.message)\n"
        } else {
            constraintHeightTextView.isActive = true
        }
        applyCaptionLayout(hasCaption: hasCaption)
    }

    override func updateUIAccordingToFileDownloadStatus() {
        super.updateUIAccordingToFileDownloadStatus()
        // The whole card is already tap-to-download via bgViewTaped(); no separate
        // button needed on the customer screen.
        retryButton.isHidden = true
        applyDownloadState()
    }

    override func setDocIconAccordingToFileType() {
        super.setDocIconAccordingToFileType()
        overlayDownloadIcon()
    }

    override func intalizeCell(with message: HippoMessage, isIncomingView: Bool) {
        // Drop a stale "open when the download finishes" intent from a previous binding.
        clearPendingOpenIfRebound(to: message)
        super.intalizeCell(with: message, isIncomingView: isIncomingView)
    }

    override func addGestureToContainer() {
        // intalizeCell adds a tap recognizer on every bind, so a reused cell fired
        // bgViewTaped several times per tap - a second firing would undo a cancel by
        // restarting the download. One recognizer per cell.
        guard !containerTapAdded else { return }
        containerTapAdded = true
        super.addGestureToContainer()
    }

    override func bgViewTaped() {
        // × on a running download - cancelling resets the card via .fileDownloadFailed.
        guard !cancelDownloadIfInProgress() else { return }
        // Not cached yet: this tap starts the download - open it once it lands.
        armOpenAfterDownloadIfNeeded()
        super.bgViewTaped()
    }

    override func fileDownloadCompleted(_ notification: Notification) {
        super.fileDownloadCompleted(notification)
        openIfPendingDownloadLanded(notification)
    }

    @objc private func fileDownloadProgressed(_ notification: Notification) {
        handleDownloadProgress(notification)
    }

    @objc private func fileDownloadFailed(_ notification: Notification) {
        handleDownloadFailed(notification)
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
        // Caption colour matches the received text bubble / image-cell caption
        // (CustomerIncomingImageCell uses hippoTextPrimary); the xib leaves it at
        // the default label colour.
        textView.textColor = colorConfig.hippoTextPrimary
        textView.tintColor = colorConfig.hippoTextPrimary
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
