//
//  DownloadProgressRingView.swift
//  Hippo
//
//  Thin ring drawn on the edge of a circular badge (the audio play button, the file
//  icon badge) while a file downloads. Two modes:
//  - indeterminate: a short arc spinning, used before the first progress tick arrives.
//  - determinate: the arc fills clockwise from 12 o'clock as `progress` goes 0 → 1.
//
//  Purely visual - user interaction is off so taps fall through to the badge beneath.
//

import UIKit

final class DownloadProgressRingView: UIView {

    var lineWidth: CGFloat = 2.4 {
        didSet { trackLayer.lineWidth = lineWidth; progressLayer.lineWidth = lineWidth; setNeedsLayout() }
    }

    var color: UIColor = .white {
        didSet { applyColors() }
    }

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private var isIndeterminate = false
    private static let spinKey = "hippo.ring.spin"
    private static let indeterminateArc: CGFloat = 0.25

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        for shape in [trackLayer, progressLayer] {
            shape.fillColor = UIColor.clear.cgColor
            shape.lineWidth = lineWidth
            shape.lineCap = .round
            layer.addSublayer(shape)
        }
        progressLayer.strokeEnd = 0
        applyColors()
    }

    private func applyColors() {
        trackLayer.strokeColor = color.withAlphaComponent(0.25).cgColor
        progressLayer.strokeColor = color.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Inset by half the stroke so the ring sits fully inside the (clipped) badge.
        let inset = lineWidth / 2
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        // Starts at 12 o'clock, runs clockwise.
        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true).cgPath
        for shape in [trackLayer, progressLayer] {
            shape.frame = bounds
            shape.path = path
        }
    }

    /// Spinning short arc - "waiting for the first byte".
    func setIndeterminate() {
        isIndeterminate = true
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = DownloadProgressRingView.indeterminateArc
        CATransaction.commit()
        startSpinIfNeeded()
    }

    /// Clockwise fill. Values are clamped to 0...1.
    func setProgress(_ progress: CGFloat) {
        if isIndeterminate {
            isIndeterminate = false
            progressLayer.removeAnimation(forKey: DownloadProgressRingView.spinKey)
        }
        progressLayer.strokeEnd = max(0, min(1, progress))
    }

    /// Back to an empty ring; call when hiding it so a reused cell doesn't flash the last value.
    func reset() {
        isIndeterminate = false
        progressLayer.removeAnimation(forKey: DownloadProgressRingView.spinKey)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = 0
        CATransaction.commit()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        // Core Animation drops running animations when a layer leaves the window
        // (e.g. a cell scrolled off and back), so restart the spin on return.
        if window != nil && isIndeterminate {
            startSpinIfNeeded()
        }
    }

    private func startSpinIfNeeded() {
        guard progressLayer.animation(forKey: DownloadProgressRingView.spinKey) == nil else { return }
        let spin = CABasicAnimation(keyPath: "transform.rotation.z")
        spin.fromValue = 0
        spin.toValue = 2 * CGFloat.pi
        spin.duration = 1
        spin.repeatCount = .infinity
        spin.isRemovedOnCompletion = false
        progressLayer.add(spin, forKey: DownloadProgressRingView.spinKey)
    }
}
