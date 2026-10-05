//
//  CustomerOutgoingAudioTableViewCell.swift
//  Hippo
//
//  Customer-only variant of OutgoingAudioTableViewCell. The revamped bubble (per-corner radii, wave
//  row, download button + progress ring) is unconditional here since this class is only ever
//  dequeued for the customer app — no appUserType branching needed inside it.
//

import UIKit
import AVFoundation

class CustomerOutgoingAudioTableViewCell: OutgoingAudioTableViewCell, CustomerAudioWaveCapable {

    @IBOutlet weak var controlsStackView: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var fileInfoContainerView: UIView!

    var waveRowInstalled = false
    var waveView: AudioWaveView?
    var durationLabel: UILabel?
    var probedTotalDuration: TimeInterval?
    var pendingAutoPlay = false
    var progressRing: DownloadProgressRingView?

    var waveActiveColor: UIColor { HippoConfig.shared.colorConfig.hippoIconPrimary }
    var waveInactiveColor: UIColor { HippoConfig.shared.colorConfig.hippoIconPrimarySurface }

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadProgressed(_:)), name: .fileDownloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadFailed(_:)), name: .fileDownloadFailed, object: nil)
        // downloadButtonView is a fixed 44x44 in the xib - same size as the file card's
        // icon badge so the two download buttons match. Hardcoded radius avoids depending
        // on bounds being resolved by Auto Layout yet. Coloured with the sender icon-pair
        // surface token.
        downloadButtonView.layer.cornerRadius = 22
        downloadButtonView.clipsToBounds = true
        downloadButtonView.backgroundColor = HippoConfig.shared.colorConfig.hippoIconPrimarySurface
        controlButton.tintColor = HippoConfig.shared.colorConfig.hippoIconPrimary
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Deferred a run-loop turn on purpose — same reason as the message bubbles:
        // CAShapeLayer.path is a one-shot bounds snapshot, and this bubble's height can take
        // more than one Auto Layout pass to settle.
        DispatchQueue.main.async { [weak self] in
            self?.bgView.applyCornerRadii(topLeft: 12, topRight: 12, bottomLeft: 12, bottomRight: 8)
        }
    }

    override func setData(message: HippoMessage) {
        super.setData(message: message)
        installWaveRowIfNeeded()
        prepareForNewMessage()
        refreshWaveRow()
        applyDownloadState()
        applyControlIconSizing()
    }

    override func setUIAccordingToTheme() {
        super.setUIAccordingToTheme()
        // Corner shape applied in layoutSubviews via applyCornerRadii — mixed per-corner radii
        // can't be expressed with cornerRadius alone.
        bgView.layer.cornerRadius = 0
        bgView.layer.borderWidth = 0

        let colorConfig = HippoConfig.shared.colorConfig
        bgView.backgroundColor = colorConfig.hippoAccent
        fileName.textColor = colorConfig.hippoOnAccent
        timeLabel.textColor = colorConfig.hippoOnAccent
    }

    override func fileDownloadCompleted(_ notification: Notification) {
        super.fileDownloadCompleted(notification)
        refreshWaveRow()
        autoPlayIfPending()
    }

    override func updateUI() {
        super.updateUI()
        refreshWaveRow()
    }

    @objc private func fileDownloadProgressed(_ notification: Notification) {
        handleDownloadProgress(notification)
    }

    @objc private func fileDownloadFailed(_ notification: Notification) {
        handleDownloadFailed(notification)
    }

    override func updateButtonAccordingToStatus() {
        super.updateButtonAccordingToStatus()
        applyDownloadState()
        applyControlIconSizing()
    }

    override func updateDownloadProgressView() {
        super.updateDownloadProgressView()
        // super restarts the spinner on every updateUI(); the ring replaces it here.
        applyDownloadState()
    }

    @IBAction override func controlButtonAction(_ sender: Any) {
        guard !cancelDownloadIfInProgress() else { return }
        // OutgoingAudioTableViewCell diverts this same tap to a retry-upload action when the
        // send itself failed - that isn't a download, so don't arm auto-play for it.
        let isRetryTap = message?.status == .none && (message?.wasMessageSendingFailed ?? false)
        if !isRetryTap {
            markAutoPlayIfNeeded()
        }
        super.controlButtonAction(sender)
    }

    override func timer(_ player: AVAudioPlayer) {
        super.timer(player)
        refreshWaveRow()
    }
}
