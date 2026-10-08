//
//  RecordingBarView.swift
//  Hippo
//
//  The in-composer voice-recording state: a trash button, a blinking red dot,
//  an m:ss elapsed label, and an animated (decorative, non-reactive) waveform.
//  Shown in place of the add-file button + text field while a voice message is
//  being recorded.
//  The send button is the composer's existing one, kept visible on top of this
//  bar. Driven entirely by ConversationsViewController - this view holds no
//  recording logic, it only renders and reports the trash tap.
//

import UIKit

final class RecordingBarView: UIView {

    /// Fired when the user taps the trash button - the controller cancels and
    /// discards the in-progress recording.
    var onTrashTapped: (() -> Void)?

    private let trashButton = UIButton(type: .system)
    private let redDot = UIView()
    private let timeLabel = UILabel()
    private let waveformView = RecordingWaveformView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Opaque - it sits on top of the add-file button row and must hide it.
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        trashButton.translatesAutoresizingMaskIntoConstraints = false
        trashButton.setImage(UIImage(systemName: "trash"), for: .normal)
        trashButton.tintColor = UIColor(white: 0.35, alpha: 1)
        trashButton.addTarget(self, action: #selector(trashTapped), for: .touchUpInside)

        redDot.translatesAutoresizingMaskIntoConstraints = false
        redDot.backgroundColor = UIColor(red: 0.98, green: 0.36, blue: 0.36, alpha: 1)
        redDot.layer.cornerRadius = 4

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        timeLabel.textColor = UIColor(white: 0.2, alpha: 1)
        timeLabel.text = "0:00"
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        [trashButton, redDot, timeLabel, waveformView].forEach(addSubview)

        NSLayoutConstraint.activate([
            trashButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            trashButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            trashButton.widthAnchor.constraint(equalToConstant: 32),
            trashButton.heightAnchor.constraint(equalToConstant: 32),

            redDot.leadingAnchor.constraint(equalTo: trashButton.trailingAnchor, constant: 10),
            redDot.centerYAnchor.constraint(equalTo: centerYAnchor),
            redDot.widthAnchor.constraint(equalToConstant: 8),
            redDot.heightAnchor.constraint(equalToConstant: 8),

            timeLabel.leadingAnchor.constraint(equalTo: redDot.trailingAnchor, constant: 8),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            waveformView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 12),
            waveformView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            waveformView.centerYAnchor.constraint(equalTo: centerYAnchor),
            waveformView.heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    /// Zero the label, start the red-dot blink and the waveform animation.
    /// Called when a recording begins.
    func reset() {
        timeLabel.text = "0:00"
        startDotBlink()
        waveformView.startAnimating()
    }

    func setElapsed(_ seconds: TimeInterval) {
        let s = max(0, Int(seconds))
        timeLabel.text = String(format: "%d:%02d", s / 60, s % 60)
    }

    /// Stop the ongoing animations. Called when a recording ends (sent or discarded).
    func stopDotBlink() {
        redDot.layer.removeAnimation(forKey: "blink")
        waveformView.stopAnimating()
    }

    private func startDotBlink() {
        redDot.layer.removeAnimation(forKey: "blink")
        let blink = CABasicAnimation(keyPath: "opacity")
        blink.fromValue = 1.0
        blink.toValue = 0.2
        blink.duration = 0.6
        blink.autoreverses = true
        blink.repeatCount = .infinity
        redDot.layer.add(blink, forKey: "blink")
    }

    @objc private func trashTapped() {
        onTrashTapped?()
    }
}

/// A row of rounded bars whose heights ripple in a repeating wave while
/// recording. Purely decorative - it does NOT track mic input.
private final class RecordingWaveformView: UIView {

    private let barWidth: CGFloat = 3
    private let gap: CGFloat = 3
    private let animationKey = "wave"

    /// Per-bar phase, so the ripple travels across the row instead of every bar
    /// pulsing together. Regenerated when the bar count changes.
    private var bars: [CALayer] = []
    private var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rebuildBarsIfNeeded()
        layoutBars()
        if isAnimating { applyAnimation() }
    }

    func startAnimating() {
        isAnimating = true
        rebuildBarsIfNeeded()
        layoutBars()
        applyAnimation()
    }

    func stopAnimating() {
        isAnimating = false
        bars.forEach { $0.removeAnimation(forKey: animationKey) }
    }

    private func neededBarCount() -> Int {
        guard bounds.width > 0 else { return 0 }
        return max(0, Int((bounds.width + gap) / (barWidth + gap)))
    }

    private func rebuildBarsIfNeeded() {
        let count = neededBarCount()
        guard count != bars.count else { return }
        bars.forEach { $0.removeFromSuperlayer() }
        bars = (0..<count).map { _ in
            let l = CALayer()
            l.backgroundColor = UIColor(white: 0.6, alpha: 1).cgColor
            l.cornerRadius = barWidth / 2
            l.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            layer.addSublayer(l)
            return l
        }
    }

    private func layoutBars() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for (i, bar) in bars.enumerated() {
            let x = CGFloat(i) * (barWidth + gap) + barWidth / 2
            bar.bounds = CGRect(x: 0, y: 0, width: barWidth, height: bounds.height)
            bar.position = CGPoint(x: x, y: bounds.midY)
            if !isAnimating {
                // Resting silhouette: a gentle fixed variation so it doesn't
                // look like a flat line before the animation kicks in.
                bar.setValue(restingScale(for: i), forKeyPath: "transform.scale.y")
            }
        }
        CATransaction.commit()
    }

    private func restingScale(for index: Int) -> CGFloat {
        let pattern: [CGFloat] = [0.35, 0.6, 0.9, 0.5, 0.75, 0.4, 0.65]
        return pattern[index % pattern.count]
    }

    private func applyAnimation() {
        guard !bars.isEmpty else { return }
        for bar in bars {
            bar.removeAnimation(forKey: animationKey)

            // Each bar gets its own slow, irregular pulse - different duration,
            // different heights, different starting phase - so the row looks like
            // real audio rather than a single sine wave sweeping across.
            var heights = (0..<5).map { _ in CGFloat.random(in: 0.22...1.0) }
            heights.append(heights[0])   // close the loop so repeats don't jump

            let anim = CAKeyframeAnimation(keyPath: "transform.scale.y")
            anim.values = heights
            anim.calculationMode = .cubic
            anim.duration = Double.random(in: 1.4...2.6)   // slower than before
            anim.repeatCount = .infinity
            anim.isRemovedOnCompletion = false
            anim.fillMode = .both
            anim.timeOffset = Double.random(in: 0...anim.duration)
            bar.add(anim, forKey: animationKey)
        }
    }
}
