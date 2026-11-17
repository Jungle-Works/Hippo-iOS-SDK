//
//  CustomerAudioWaveCapable.swift
//  Hippo
//
//  Wave-row install/refresh/seek/auto-download orchestration for the customer audio revamp.
//  Deliberately customer-only and NOT part of AudioTableViewCell: a future agent audio revamp
//  gets its own orchestration (it may reuse the generic AudioWaveView/AudioPlayerManager, but
//  its policy — layout, auto-download rules — shouldn't be forced through this one).
//
//  Default-implemented against `Self: AudioTableViewCell` so CustomerIncomingAudioTableViewCell
//  and CustomerOutgoingAudioTableViewCell can both adopt it without a shared ancestor beyond
//  AudioTableViewCell itself, which stays untouched.
//

import UIKit
import AVFoundation

/// Centre glyph while a download is running - tapping the button then cancels it.
private let downloadCancelIcon = UIImage(systemName: "xmark",
                                         withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))?
    .withRenderingMode(.alwaysTemplate)

protocol CustomerAudioWaveCapable: AnyObject {
    var controlsStackView: UIStackView! { get }
    var downloadButtonView: UIView! { get }
    var iconImageView: UIImageView! { get }
    var fileInfoContainerView: UIView! { get }

    var waveRowInstalled: Bool { get set }
    var waveView: AudioWaveView? { get set }
    var durationLabel: UILabel? { get set }
    var probedTotalDuration: TimeInterval? { get set }
    /// Ring on the edge of `downloadButtonView` while the audio file downloads.
    var progressRing: DownloadProgressRingView? { get set }

    /// Icon-pair tokens for this cell's side — primary for outgoing, secondary for incoming.
    var waveActiveColor: UIColor { get }
    var waveInactiveColor: UIColor { get }

    /// Set when a tap on the download button starts a download, so playback starts on its
    /// own once that download finishes - no second tap on play needed.
    var pendingAutoPlay: Bool { get set }
}

extension CustomerAudioWaveCapable where Self: AudioTableViewCell {

    /// Builds the [button][wave][duration] row once per cell instance. `downloadButtonView` is
    /// an existing arranged subview of `controlsStackView` — today it sits last (after the icon
    /// and file-info view); its position is purely a function of its index in the stack, so
    /// moving it to the front is a single `insertArrangedSubview` call, not a new view.
    func installWaveRowIfNeeded() {
        guard !waveRowInstalled else { return }
        guard let stack = controlsStackView, let button = downloadButtonView else { return }
        waveRowInstalled = true

        iconImageView?.isHidden = true
        fileInfoContainerView?.isHidden = true

        stack.insertArrangedSubview(button, at: 0)

        let ring = DownloadProgressRingView()
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.isHidden = true
        button.addSubview(ring)
        NSLayoutConstraint.activate([
            ring.topAnchor.constraint(equalTo: button.topAnchor),
            ring.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            ring.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            ring.trailingAnchor.constraint(equalTo: button.trailingAnchor)
        ])
        progressRing = ring

        let wave = AudioWaveView()
        wave.translatesAutoresizingMaskIntoConstraints = false
        wave.widthAnchor.constraint(equalToConstant: 110).isActive = true
        wave.heightAnchor.constraint(equalToConstant: 28).isActive = true
        wave.activeColor = waveActiveColor
        wave.inactiveColor = waveInactiveColor
        wave.onSeeking = { [weak self] fraction in
            self?.seek(toFraction: fraction)
        }
        wave.onSeekTo = { [weak self] fraction in
            self?.seek(toFraction: fraction)
        }
        stack.insertArrangedSubview(wave, at: 1)
        waveView = wave

        let duration = UILabel()
        duration.translatesAutoresizingMaskIntoConstraints = false
        duration.font = totalTimeLabel?.font ?? UIFont.systemFont(ofSize: 10)
        duration.textColor = totalTimeLabel?.textColor ?? .darkGray
        duration.textAlignment = .left
        // Without a hugging priority, this is the only arranged subview without a fixed width
        // (button and wave both have explicit size constraints), so a fill-distribution stack
        // stretches its frame to absorb the row's leftover width - right-aligned text in that
        // stretched frame reads as "far from the wave" even though the view itself sits right
        // next to it. Hugging keeps the label's frame at its own intrinsic size instead.
        duration.setContentHuggingPriority(.required, for: .horizontal)
        stack.insertArrangedSubview(duration, at: 2)
        stack.setCustomSpacing(4, after: wave)
        durationLabel = duration
    }

    /// Resets per-message cached state. Call once per `setData()`, before `refreshWaveRow`, so
    /// a recycled cell doesn't show a previous message's probed duration or auto-play a
    /// download that belonged to whatever message this cell was recycled from.
    func prepareForNewMessage() {
        probedTotalDuration = nil
        pendingAutoPlay = false
    }

    /// Call from `controlButtonAction(_:)` before `super` — records whether this tap is the
    /// one starting the download, so `autoPlayIfPending()` knows to act once it lands.
    func markAutoPlayIfNeeded() {
        if !isFileDownloaded() && !isFileBeingDownloaded() {
            pendingAutoPlay = true
        }
    }

    /// Call from `fileDownloadCompleted(_:)` — starts playback if this cell was waiting on the
    /// download that just finished. Re-checking `isFileDownloaded()` here (rather than trusting
    /// the notification alone) keeps this correct even though the completion notification is
    /// broadcast for every cell, not just this one.
    func autoPlayIfPending() {
        guard pendingAutoPlay, isFileDownloaded() else { return }
        pendingAutoPlay = false
        controlButtonAction(self)
    }

    /// Call from `updateButtonAccordingToStatus()` and `updateDownloadProgressView()` after
    /// `super`. Not downloaded: the base class already shows the download icon - just dim the
    /// wave. Downloading: swap the base class's spinner for the progress ring and show × in
    /// the button (tap cancels). Downloaded: nothing to do, the base class shows play/pause.
    func applyDownloadState() {
        guard waveRowInstalled else { return }
        waveView?.alpha = isFileDownloaded() ? 1 : 0.45

        guard isFileBeingDownloaded() else {
            progressRing?.reset()
            progressRing?.isHidden = true
            return
        }
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        controlButton.isHidden = false
        controlButton.setImage(downloadCancelIcon, for: .normal)
        controlButton.imageEdgeInsets = .zero

        guard let ring = progressRing else { return }
        ring.color = controlButton.tintColor
        ring.isHidden = false
        if let progress = DownloadManager.shared.downloadProgressFor(url: cellIdentifier) {
            ring.setProgress(progress)
        } else {
            ring.setIndeterminate()
        }
    }

    /// Call from `controlButtonAction(_:)` first - returns true (and the caller should stop)
    /// when the tap was the × on a running download.
    func cancelDownloadIfInProgress() -> Bool {
        guard isFileBeingDownloaded() else { return false }
        pendingAutoPlay = false
        // Ends in a `.fileDownloadFailed` notification, which resets the button.
        DownloadManager.shared.cancelDownloadWith(url: cellIdentifier)
        return true
    }

    /// Call from the cell's `.fileDownloadProgress` observer.
    func handleDownloadProgress(_ notification: Notification) {
        guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String,
              url == cellIdentifier else { return }
        applyDownloadState()
    }

    /// Call from the cell's `.fileDownloadFailed` observer (also fired on cancel).
    func handleDownloadFailed(_ notification: Notification) {
        guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String,
              url == cellIdentifier else { return }
        pendingAutoPlay = false
        updateUI()
    }

    func seek(toFraction fraction: CGFloat) {
        guard AudioPlayerManager.shared.tag == cellIdentifier, AudioPlayerManager.shared.duration > 0 else {
            // Not the active player (or nothing loaded yet) - the pan gesture already painted a
            // stale scrub position on the wave; refreshWaveRow() puts it back to the real state.
            refreshWaveRow()
            return
        }
        AudioPlayerManager.shared.seek(to: TimeInterval(fraction) * AudioPlayerManager.shared.duration)
        refreshWaveRow()
    }

    /// Repaints the wave's fill/progress and the duration label. Idle shows the total duration;
    /// playing shows elapsed time, counting up. Call after any state change that could affect
    /// playback position or download state.
    func refreshWaveRow() {
        guard waveRowInstalled else { return }
        waveView?.setSeed(message?.messageUniqueID ?? cellIdentifier)

        let isActivePlayer = AudioPlayerManager.shared.tag == cellIdentifier
        if isActivePlayer {
            let total = AudioPlayerManager.shared.duration
            let elapsed = AudioPlayerManager.shared.currentTime
            let isPlaying = AudioPlayerManager.shared.audioPlayer?.isPlaying ?? false
            waveView?.setProgress(total > 0 ? CGFloat(elapsed / total) : 0)
            durationLabel?.text = isPlaying
                ? getMintues(from: elapsed) + ":" + getSeconds(from: elapsed)
                : getMintues(from: total) + ":" + getSeconds(from: total)
            return
        }

        waveView?.setProgress(0)
        guard isFileDownloaded() else {
            durationLabel?.text = ""
            return
        }
        if probedTotalDuration == nil {
            probedTotalDuration = probeLocalDuration()
        }
        let total = probedTotalDuration ?? 0
        durationLabel?.text = total > 0 ? getMintues(from: total) + ":" + getSeconds(from: total) : ""
    }

    /// Reads duration straight off the local file header — cheap for an already-downloaded
    /// file, and the only way to know total duration before the message has ever been played
    /// (before then, `AudioPlayerManager` has no `AVAudioPlayer` instance for this message yet).
    func probeLocalDuration() -> TimeInterval? {
        guard let localPathString = DownloadManager.shared.getLocalPathOf(url: cellIdentifier),
              let url = URL(string: localPathString) else { return nil }
        // Same fallback ladder as playback — a bare AVAudioPlayer(contentsOf:) can't
        // open a .aac (ADTS) or extension-less cached file.
        return AudioPlayerManager.makePlayer(for: url)?.duration
    }

    /// Shrinks the play/pause glyph inside `controlButton` without touching the fixed-size
    /// circular badge behind it, and nudges the play triangle right to correct its optical
    /// centring. Call after anything that may have changed `controlButton`'s image
    /// (`updateButtonAccordingToStatus()` is the only place that sets play/pause).
    ///
    /// A right-pointing triangle's filled area sits left of its bounding box's geometric
    /// centre — the flat edge is on the left, the point tapers away on the right — so simply
    /// centring the (unrotated) glyph in the badge reads as "shifted left". The pause glyph
    /// (two symmetric bars) has no such bias and keeps zero insets.
    func applyControlIconSizing() {
        let theme = HippoConfig.shared.theme
        let currentImage = controlButton.currentImage
        let isPlayIcon = currentImage === theme.playIcon
        let isPauseIcon = currentImage === theme.pauseIcon
        if currentImage === theme.downloadIcon {
            // Drawn at its own size, not shrunk: the file card shows this same asset
            // unscaled, and downscaling thins its strokes so the two stop matching.
            controlButton.imageEdgeInsets = .zero
            return
        }
        guard isPlayIcon || isPauseIcon else { return }

        let targetSize = CGSize(width: 14, height: 14)
        if currentImage?.size != targetSize {
            controlButton.setImage(resized(currentImage, to: targetSize), for: .normal)
        }
        controlButton.imageEdgeInsets = isPlayIcon
            ? UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
            : .zero
    }

    private func resized(_ image: UIImage?, to size: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }
            .withRenderingMode(image.renderingMode)
    }
}
