//
//  CustomerIncomingAudioTableViewCell.swift
//  Hippo
//
//  Customer-only variant of IncomingAudioTableViewCell. The revamped bubble (per-corner radii, wave
//  row, download button + progress ring, no sender-name row) is unconditional here since this class
//  is only ever dequeued for the customer app — no appUserType branching needed inside it.
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
    var progressRing: DownloadProgressRingView?

    /// Text sent along with the audio file (e.g. from the web dashboard). The xib has no
    /// caption view, so it's added to the bubble's vertical stack, between the controls row
    /// and the time row. Hidden when empty, so captionless audio keeps its layout.
    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    private var captionInstalled = false

    var waveActiveColor: UIColor { HippoConfig.shared.colorConfig.hippoIconSecondary }
    var waveInactiveColor: UIColor { HippoConfig.shared.colorConfig.hippoIconSecondarySurface }

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadProgressed(_:)), name: .fileDownloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadFailed(_:)), name: .fileDownloadFailed, object: nil)
        // downloadButtonView is a fixed 44x44 in the xib - same size as the file card's
        // icon badge so the two download buttons match. Hardcoded radius avoids depending
        // on bounds being resolved by Auto Layout yet. Coloured with the receiver icon-pair
        // surface token.
        downloadButtonView.layer.cornerRadius = 22
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
        // Set here, not in layoutSubviews: the self-sizing row is measured right after configure.
        applyCaption(message.message)
        installWaveRowIfNeeded()
        prepareForNewMessage()
        refreshWaveRow()
        applyDownloadState()
        applyControlIconSizing()
    }

    private func applyCaption(_ text: String) {
        if !captionInstalled,
           let bubbleStack = controlsStackView.superview as? UIStackView,
           let controlsIndex = bubbleStack.arrangedSubviews.firstIndex(of: controlsStackView) {
            bubbleStack.insertArrangedSubview(captionLabel, at: controlsIndex + 1)
            bubbleStack.setCustomSpacing(6, after: controlsStackView)
            captionInstalled = true
        }
        let caption = text.trimmingCharacters(in: .whitespacesAndNewlines)
        captionLabel.text = caption
        // Same 14pt system font as the document/video/image captions (set in their xibs).
        captionLabel.font = UIFont.systemFont(ofSize: 14)
        captionLabel.textColor = HippoConfig.shared.colorConfig.hippoTextPrimary
        captionLabel.isHidden = caption.isEmpty
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
        timeLabel.textColor = colorConfig.hippoTextMuted
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
        markAutoPlayIfNeeded()
        super.controlButtonAction(sender)
    }

    override func timer(_ player: AVAudioPlayer) {
        super.timer(player)
        refreshWaveRow()
    }
}
