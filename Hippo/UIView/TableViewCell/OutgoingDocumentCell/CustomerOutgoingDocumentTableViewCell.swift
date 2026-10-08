//
//  CustomerOutgoingDocumentTableViewCell.swift
//  Hippo
//
//  Customer-only variant of OutgoingDocumentTableViewCell. The revamped file card
//  (bigger badge-backed icon, file size/type aligned under the filename, download
//  states drawn in the badge - see CustomerDocumentDownloadCapable) is unconditional
//  here since this class is only ever dequeued for the customer app.
//

import UIKit

class CustomerOutgoingDocumentTableViewCell: OutgoingDocumentTableViewCell, CustomerDocumentDownloadCapable {

    @IBOutlet weak var docImageBadgeView: UIView!

    var pendingOpenFileUrl: String?
    var progressRing: DownloadProgressRingView?
    private var containerTapAdded = false

    /// Mirrors OutgoingDocumentTableViewCell.updateUIAccordingToFileDownloadStatus(): while
    /// the send is pending or failed the badge belongs to the upload state.
    var isDownloadStateApplicable: Bool {
        guard let message = message else { return false }
        return message.status != .none && !message.wasMessageSendingFailed
    }

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
        // Drop a stale "open when the download finishes" intent from a previous binding -
        // but not when bgViewTaped() re-binds this same file right after arming it.
        clearPendingOpenIfRebound(to: message)
        super.intalizeCell(with: message, isIncomingView: isIncomingView)
    }

    override func addGestureToContainer() {
        // intalizeCell adds a tap recognizer on every bind (and bgViewTaped re-binds), so one
        // tap fired bgViewTaped several times - harmless before, but now a second firing
        // would undo a cancel by restarting the download. One recognizer per cell.
        guard !containerTapAdded else { return }
        containerTapAdded = true
        super.addGestureToContainer()
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
            // × on a running download - cancelling resets the card via .fileDownloadFailed.
            if cancelDownloadIfInProgress() { return }
            // If the file isn't cached yet this tap starts a download - remember to
            // auto-open it when fileDownloadCompleted(_:) fires. If it's already
            // downloaded, performActionAccordingToStatusOf opens it right here.
            armOpenAfterDownloadIfNeeded()
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
