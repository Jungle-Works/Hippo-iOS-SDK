//
//  CustomerIncomingAudioTableViewCell.swift
//  Hippo
//
//  Customer-only variant of IncomingAudioTableViewCell. The revamped bubble (per-corner radii,
//  wave row, auto-download, no sender-name row) is unconditional here since this class is only
//  ever dequeued for the customer app — no appUserType branching needed inside it.
//

import UIKit
import AVFoundation

class CustomerIncomingAudioTableViewCell: IncomingAudioTableViewCell, CustomerAudioWaveCapable {

    @IBOutlet weak var controlsStackView: UIStackView!
    @IBOutlet weak var downloadButtonView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var fileInfoContainerView: UIView!
    @IBOutlet weak var senderNameLabelHeightConstraint: NSLayoutConstraint!

    var waveRowInstalled = false
    var waveView: AudioWaveView?
    var durationLabel: UILabel?
    var probedTotalDuration: TimeInterval?
    var pendingAutoPlay = false

    var waveActiveColor: UIColor { HippoConfig.shared.colorConfig.hippoIconSecondary }
    var waveInactiveColor: UIColor { HippoConfig.shared.colorConfig.hippoIconSecondarySurface }

    override func awakeFromNib() {
        super.awakeFromNib()
        // downloadButtonView is a fixed 40x40 in the xib (bumped from 36x36 to match the
        // sender-side badge) - hardcoded radius avoids depending on bounds being resolved by
        // Auto Layout yet. Same circular badge as the file icon, coloured with the receiver
        // icon-pair surface token.
        downloadButtonView.layer.cornerRadius = 20
        downloadButtonView.clipsToBounds = true
        downloadButtonView.backgroundColor = HippoConfig.shared.colorConfig.hippoIconSecondarySurface
        controlButton.tintColor = HippoConfig.shared.colorConfig.hippoIconSecondary
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Deferred a run-loop turn on purpose — same reason as the message bubbles:
        // CAShapeLayer.path is a one-shot bounds snapshot, and this bubble's height can take
        // more than one Auto Layout pass to settle.
        DispatchQueue.main.async { [weak self] in
            self?.bgView.applyCornerRadii(topLeft: 12, topRight: 12, bottomLeft: 8, bottomRight: 12)
        }
    }

    override func setData(message: HippoMessage) {
        super.setData(message: message)
        installWaveRowIfNeeded()
        prepareForNewMessage()
        refreshWaveRow()
    }

    override func setUIAccordingToTheme() {
        super.setUIAccordingToTheme()
        // Corner shape applied in layoutSubviews via applyCornerRadii — mixed per-corner radii
        // can't be expressed with cornerRadius alone.
        bgView.layer.cornerRadius = 0
        bgView.layer.borderWidth = 0
        senderNameLabel.isHidden = true
        senderNameLabelHeightConstraint?.isActive = true

        let colorConfig = HippoConfig.shared.colorConfig
        bgView.backgroundColor = colorConfig.hippoReceiver
        fileName.textColor = colorConfig.hippoTextPrimary
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

    override func updateButtonAccordingToStatus() {
        super.updateButtonAccordingToStatus()
        suppressDownloadIcon()
        applyControlIconSizing()
    }

    @IBAction override func controlButtonAction(_ sender: Any) {
        markAutoPlayIfNeeded()
        super.controlButtonAction(sender)
    }

    override func timer(_ player: AVAudioPlayer) {
        super.timer(player)
        refreshWaveRow()
    }
}
