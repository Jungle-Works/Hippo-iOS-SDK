//
//  CustomerDocumentDownloadCapable.swift
//  Hippo
//
//  Download states for the customer file cards, shared by CustomerIncomingDocumentTableViewCell
//  and CustomerOutgoingDocumentTableViewCell. Customer-only, like CustomerAudioWaveCapable -
//  the legacy/agent DocumentTableViewCell keeps its retry-button download flow untouched.
//
//  States, all drawn inside the existing `docImageBadgeView`:
//  - not downloaded: download arrow instead of the file-type icon; tap downloads.
//  - downloading: progress ring on the badge edge, × in the middle (tap cancels),
//    "NN% · size" in the size label.
//  - downloaded: file-type icon as before; tap opens. A download started by a tap
//    opens the file automatically once it lands.
//

import UIKit

/// Centre glyph while a download is running - tapping the card then cancels it.
private let downloadCancelIcon = UIImage(systemName: "xmark",
                                         withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))?
    .withRenderingMode(.alwaysTemplate)

protocol CustomerDocumentDownloadCapable: AnyObject {
    var docImageBadgeView: UIView! { get }
    var progressRing: DownloadProgressRingView? { get set }

    /// Set to the message's file URL when a tap kicks off a fresh download, so the file
    /// opens automatically once it lands instead of needing a second tap.
    var pendingOpenFileUrl: String? { get set }

    /// False while this cell's own state owns the badge (e.g. a sent file still
    /// uploading, or a failed send) - download visuals stay out of the way then.
    var isDownloadStateApplicable: Bool { get }
}

extension CustomerDocumentDownloadCapable where Self: DocumentTableViewCell {

    /// Call once from `awakeFromNib`.
    func installProgressRing() {
        guard progressRing == nil, let badge = docImageBadgeView else { return }
        let ring = DownloadProgressRingView()
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.isHidden = true
        badge.addSubview(ring)
        NSLayoutConstraint.activate([
            ring.topAnchor.constraint(equalTo: badge.topAnchor),
            ring.bottomAnchor.constraint(equalTo: badge.bottomAnchor),
            ring.leadingAnchor.constraint(equalTo: badge.leadingAnchor),
            ring.trailingAnchor.constraint(equalTo: badge.trailingAnchor)
        ])
        progressRing = ring
    }

    /// Swaps the file-type icon for the download arrow / × while the file isn't local.
    /// Call from a `setDocIconAccordingToFileType()` override, after `super`.
    func overlayDownloadIcon() {
        guard isDownloadStateApplicable, let fileUrl = message?.fileUrl,
              !DownloadManager.shared.isFileDownloadedWith(url: fileUrl) else {
            docImage.contentMode = .scaleAspectFit
            return
        }
        // .center keeps the arrow / × at their own (smaller) size inside the 24pt slot
        // rather than stretching them to fill it like the file-type icons.
        docImage.contentMode = .center
        docImage.image = DownloadManager.shared.isFileBeingDownloadedWith(url: fileUrl)
            ? downloadCancelIcon
            : HippoConfig.shared.theme.downloadIcon
    }

    /// Call from `updateUIAccordingToFileDownloadStatus()` after `super`, and on progress.
    func applyDownloadState() {
        // Icon stays visible in every state now - the arrow / × replace it instead of the
        // old "hide the icon under the spinner".
        docImage.isHidden = false
        guard isDownloadStateApplicable, let fileUrl = message?.fileUrl,
              DownloadManager.shared.isFileBeingDownloadedWith(url: fileUrl) else {
            hideProgressRing()
            setDocIconAccordingToFileType()
            if isDownloadStateApplicable {
                // Drops any "NN% · " prefix left from a download that just ended.
                updateDataInView()
            }
            return
        }

        // The ring replaces the base class's spinner, which sits on the same badge.
        activityIndicator.stopAnimating()
        setDocIconAccordingToFileType()

        guard let ring = progressRing else { return }
        ring.color = docImage.tintColor
        ring.isHidden = false
        updateDataInView()
        if let progress = DownloadManager.shared.downloadProgressFor(url: fileUrl) {
            ring.setProgress(progress)
            let percent = "\(Int(progress * 100))%"
            let size = fileSizeLabel.text ?? ""
            fileSizeLabel.text = size.isEmpty ? percent : percent + " · " + size
        } else {
            ring.setIndeterminate()
        }
    }

    private func hideProgressRing() {
        progressRing?.reset()
        progressRing?.isHidden = true
    }

    /// Call at the top of the card tap - returns true (and the caller should stop) when
    /// the tap was the × on a running download.
    func cancelDownloadIfInProgress() -> Bool {
        guard isDownloadStateApplicable, let fileUrl = message?.fileUrl,
              DownloadManager.shared.isFileBeingDownloadedWith(url: fileUrl) else { return false }
        pendingOpenFileUrl = nil
        // Ends in a `.fileDownloadFailed` notification, which resets the card.
        DownloadManager.shared.cancelDownloadWith(url: fileUrl)
        return true
    }

    /// Call from the card tap before handing off to `performActionAccordingToStatusOf`.
    func armOpenAfterDownloadIfNeeded() {
        guard let fileUrl = message?.fileUrl,
              !DownloadManager.shared.isFileDownloadedWith(url: fileUrl) else { return }
        pendingOpenFileUrl = fileUrl
    }

    /// Call from `intalizeCell(with:isIncomingView:)` before `super`. Only drops the pending
    /// open when the cell is being bound to a *different* file - the outgoing card re-binds
    /// the same message straight after a tap, which must not cancel the auto-open.
    func clearPendingOpenIfRebound(to message: HippoMessage) {
        if pendingOpenFileUrl != message.fileUrl {
            pendingOpenFileUrl = nil
        }
    }

    /// Call from `fileDownloadCompleted(_:)` after `super` - opens the file if this cell's
    /// tap started the download that just finished.
    func openIfPendingDownloadLanded(_ notification: Notification) {
        guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String,
              url == pendingOpenFileUrl,
              let message = message,
              message.fileUrl == url,
              DownloadManager.shared.isFileDownloadedWith(url: url) else {
            return
        }
        pendingOpenFileUrl = nil
        // Going back through performActionAccordingToStatusOf keeps the "already downloaded ->
        // QuickLook" branch as the single place that opens files.
        actionDelegate?.performActionAccordingToStatusOf(message: message, inCell: self)
    }

    /// Call from the cell's `.fileDownloadProgress` observer.
    func handleDownloadProgress(_ notification: Notification) {
        guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String,
              url == message?.fileUrl else { return }
        applyDownloadState()
    }

    /// Call from the cell's `.fileDownloadFailed` observer (also fired on cancel).
    func handleDownloadFailed(_ notification: Notification) {
        guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String,
              url == message?.fileUrl else { return }
        pendingOpenFileUrl = nil
        updateUIAccordingToFileDownloadStatus()
    }
}
