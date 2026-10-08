//
//  AudioWaveView.swift
//  Hippo
//
//  Waveform strip for voice messages. Bars are drawn in a muted colour and re-drawn in the
//  active colour up to the current playback position, so the row fills left-to-right as the
//  clip plays.
//
//  Bar heights are derived from the message's unique id rather than the audio itself: a decode
//  pass would need the file on disk, which isn't true for received audio until it downloads.
//  Seeding off the id gives every message its own stable silhouette for free.
//

import UIKit

final class AudioWaveView: UIView {

    private static let levelMax = 100
    // Never let a bar collapse to nothing - a flat run of silence should still read as a bar.
    private static let minBarFraction: CGFloat = 0.18

    var barCount: Int = 14
    var barWidth: CGFloat = 4
    var barGap: CGFloat = 2
    var inactiveColor: UIColor = UIColor(white: 0.82, alpha: 1) { didSet { setNeedsDisplay() } }
    var activeColor: UIColor = UIColor(white: 0.35, alpha: 1) { didSet { setNeedsDisplay() } }

    private(set) var levels: [Int] = []
    private(set) var progress: CGFloat = 0

    /// Fired continuously while the finger is down, for previewing the target position.
    var onSeeking: ((CGFloat) -> Void)?
    /// Fired on release - the one that should actually move playback.
    var onSeekTo: ((CGFloat) -> Void)?

    private var progressBeforeScrub: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)
    }

    /// Gives this view the silhouette belonging to `seed` (the message's unique id). Same seed
    /// always yields the same bars, so a recycled row redraws identically.
    func setSeed(_ seed: String) {
        levels = AudioWaveView.generateLevels(seed: seed, count: barCount)
        setNeedsDisplay()
    }

    /// Explicit bar heights, each 0...100. Escape hatch for real per-bucket amplitudes later.
    func setLevels(_ levels: [Int]) {
        self.levels = levels
        setNeedsDisplay()
    }

    /// Playback position, 0...1. Bars up to it are drawn active.
    func setProgress(_ progress: CGFloat) {
        self.progress = min(max(progress, 0), 1)
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !levels.isEmpty, let context = UIGraphicsGetCurrentContext() else { return }
        let usableWidth = bounds.width
        let usableHeight = bounds.height
        guard usableWidth > 0, usableHeight > 0 else { return }

        let pitch = (usableWidth + barGap) / CGFloat(levels.count)
        let width = min(barWidth, max(1, pitch - barGap))
        let centerY = usableHeight / 2

        // Whole strip in the muted colour first, then the played portion painted over it
        // clipped to the playhead. Clipping rather than colouring per bar makes the fill
        // continuous - the bar straddling the playhead renders part-filled, not all-or-nothing.
        drawBars(color: inactiveColor, pitch: pitch, barWidth: width, centerY: centerY, usableHeight: usableHeight)

        if progress > 0 {
            let playheadX = usableWidth * progress
            context.saveGState()
            context.clip(to: CGRect(x: 0, y: 0, width: playheadX, height: usableHeight))
            drawBars(color: activeColor, pitch: pitch, barWidth: width, centerY: centerY, usableHeight: usableHeight)
            context.restoreGState()
        }
    }

    private func drawBars(color: UIColor, pitch: CGFloat, barWidth: CGFloat, centerY: CGFloat, usableHeight: CGFloat) {
        color.setFill()
        for (index, level) in levels.enumerated() {
            let clampedLevel = min(max(level, 0), AudioWaveView.levelMax)
            let fraction = AudioWaveView.minBarFraction
                + (1 - AudioWaveView.minBarFraction) * CGFloat(clampedLevel) / CGFloat(AudioWaveView.levelMax)
            let halfHeight = usableHeight * fraction / 2
            let left = CGFloat(index) * pitch
            let rect = CGRect(x: left, y: centerY - halfHeight, width: barWidth, height: halfHeight * 2)
            UIBezierPath(roundedRect: rect, cornerRadius: barWidth / 2).fill()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let x = gesture.location(in: self).x
        switch gesture.state {
        case .began:
            progressBeforeScrub = progress
        case .changed:
            let fraction = fractionForX(x)
            setProgress(fraction)
            onSeeking?(fraction)
        case .ended:
            let fraction = fractionForX(x)
            setProgress(fraction)
            onSeekTo?(fraction)
        case .cancelled:
            // Gesture was taken away, not committed - put the bar back.
            setProgress(progressBeforeScrub)
        default:
            break
        }
    }

    private func fractionForX(_ x: CGFloat) -> CGFloat {
        guard bounds.width > 0 else { return 0 }
        return min(max(x / bounds.width, 0), 1)
    }

    /// Deterministic pseudo-random heights. `String.hashValue` is NOT used here - it's
    /// randomized per process launch in Swift, which would reshuffle every wave's shape on
    /// every app relaunch. `stableHash` is a plain Java-`String.hashCode()`-style rolling hash
    /// instead, so the same message id always produces the same silhouette.
    static func stableHash(_ s: String) -> Int32 {
        var hash: Int32 = 0
        for scalar in s.unicodeScalars {
            hash = 31 &* hash &+ Int32(scalar.value)
        }
        return hash
    }

    private static func generateLevels(seed: String, count: Int) -> [Int] {
        let hashValue = seed.isEmpty ? Int32(bitPattern: 0x9E3779B9) : stableHash(seed)
        var state = UInt32(bitPattern: hashValue)
        if state == 0 {
            state = UInt32(bitPattern: Int32(bitPattern: 0x9E3779B9))
        }
        var out: [Int] = []
        out.reserveCapacity(max(count, 0))
        for _ in 0..<max(count, 0) {
            state ^= state << 13
            state ^= state >> 17
            state ^= state << 5
            // Bias towards the middle of the range so the strip reads as speech, not noise
            // pinned to both extremes.
            let a = Int(state % UInt32(levelMax))
            let b = Int((state >> 8) % UInt32(levelMax))
            out.append((a + b) / 2)
        }
        return out
    }
}

extension AudioWaveView: UIGestureRecognizerDelegate {
    /// Only begins for a predominantly-horizontal drag, so a vertical drag starting on the wave
    /// falls through to the table view's own scroll instead of being captured here.
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pan.velocity(in: self)
        return abs(velocity.x) > abs(velocity.y)
    }
}
