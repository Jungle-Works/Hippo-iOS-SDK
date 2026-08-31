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

protocol CustomerAudioWaveCapable: AnyObject {
    var controlsStackView: UIStackView! { get }
    var downloadButtonView: UIView! { get }
    var iconImageView: UIImageView! { get }
    var fileInfoContainerView: UIView! { get }

    var waveRowInstalled: Bool { get set }
    var waveView: AudioWaveView? { get set }
    var durationLabel: UILabel? { get set }
    var probedTotalDuration: TimeInterval? { get set }

    /// Icon-pair tokens for this cell's side — primary for outgoing, secondary for incoming.
    var waveActiveColor: UIColor { get }
    var waveInactiveColor: UIColor { get }

    /// Set when a tap arrives before the file is local, so playback can start on its own once
    /// the download this tap kicked off finishes — the button no longer distinguishes
    /// "download" from "play", so one tap has to do both.
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

    /// Call from `updateButtonAccordingToStatus()` after `super` — the badge's spinner already
    /// communicates "downloading"; the button itself should only ever read as play/pause, never
    /// show the base class's separate "download" icon.
    func suppressDownloadIcon() {
        guard controlButton.currentImage === HippoConfig.shared.theme.downloadIcon else { return }
        controlButton.setImage(HippoConfig.shared.theme.playIcon, for: .normal)
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
        return (try? AVAudioPlayer(contentsOf: url))?.duration
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
