//
//  HippoColorConfig.swift
//  Hippo
//
//  Semantic colour tokens for the revamped customer chat screen: a small settable surface
//  (13 tokens + 2 icon pairs + 1 call-icon pair) plus derived "ladder" tokens computed from it,
//  so an integrator only sets the meaningful few and every dependent shade (call-card fills,
//  icon badges) stays in family automatically. Mirrors the Android HippoColorConfig token set
//  and math 1:1 so the two platforms theme the same way from the same values.
//

import UIKit

@objcMembers public class HippoColorConfig: NSObject {

    // MARK: - Settable tokens (13)

    private var hippoSurfaceHex: String?
    private var hippoSurfaceBackgroundHex: String?
    private var hippoSurfaceInputHex: String?
    private var hippoBorderHex: String?
    private var hippoTextPrimaryHex: String?
    private var hippoTextMutedHex: String?
    private var hippoAccentHex: String?
    private var hippoOnAccentHex: String?
    private var hippoReceiverHex: String?
    private var hippoErrorHex: String?
    private var hippoSuccessHex: String?
    private var hippoWarningHex: String?
    private var hippoScrimHex: String?

    // MARK: - Icon-pair tokens (settable)

    private var hippoIconPrimaryHex: String?
    private var hippoIconPrimarySurfaceHex: String?
    private var hippoIconSecondaryHex: String?
    private var hippoIconSecondarySurfaceHex: String?

    // MARK: - Call-icon-pair tokens (settable; nil = derive from the card underneath)

    private var hippoCallIconPrimaryHex: String?
    private var hippoCallIconPrimarySurfaceHex: String?
    private var hippoCallIconSecondaryHex: String?
    private var hippoCallIconSecondarySurfaceHex: String?
    private var hippoCallIconMissedHex: String?
    private var hippoCallIconMissedSurfaceHex: String?

    // MARK: - Resolved settable tokens

    public var hippoSurface: UIColor { Self.parseOr(hippoSurfaceHex, "#FFFFFF") }
    public var hippoSurfaceBackground: UIColor { Self.parseOr(hippoSurfaceBackgroundHex, "#EEF1F5") }
    public var hippoSurfaceInput: UIColor { Self.parseOr(hippoSurfaceInputHex, "#F1F3F6") }
    public var hippoBorder: UIColor { Self.parseOr(hippoBorderHex, "#ECEEF2") }
    public var hippoTextPrimary: UIColor { Self.parseOr(hippoTextPrimaryHex, "#0F1420") }
    public var hippoTextMuted: UIColor { Self.parseOr(hippoTextMutedHex, "#6B7280") }
    public var hippoAccent: UIColor { Self.parseOr(hippoAccentHex, "#3B5BDB") }
    public var hippoOnAccent: UIColor { Self.parseOr(hippoOnAccentHex, "#FFFFFF") }
    public var hippoReceiver: UIColor { Self.parseOr(hippoReceiverHex, "#FFFFFF") }
    public var hippoError: UIColor { Self.parseOr(hippoErrorHex, "#EF4444") }
    public var hippoSuccess: UIColor { Self.parseOr(hippoSuccessHex, "#15803D") }
    public var hippoWarning: UIColor { Self.parseOr(hippoWarningHex, "#F5A623") }
    /// Alpha-first ARGB default (`#660F1420`), matching the Android token verbatim.
    public var hippoScrim: UIColor { Self.parseOr(hippoScrimHex, "#660F1420") }

    public var hippoIconPrimary: UIColor { Self.parseOr(hippoIconPrimaryHex, "#FFFFFF") }
    public var hippoIconPrimarySurface: UIColor { Self.parseOr(hippoIconPrimarySurfaceHex, "#33FFFFFF") }
    public var hippoIconSecondary: UIColor { Self.parseOr(hippoIconSecondaryHex, "#5F6368") }
    public var hippoIconSecondarySurface: UIColor { Self.parseOr(hippoIconSecondarySurfaceHex, "#F0F2F5") }

    // MARK: - Resolved call-icon-pair tokens (settable, else derived)

    public var hippoCallIconPrimary: UIColor { Self.parseOrDerived(hippoCallIconPrimaryHex, hippoAccent) }
    public var hippoCallIconPrimarySurface: UIColor { Self.parseOrDerived(hippoCallIconPrimarySurfaceHex, hippoAccentSubtle3) }
    public var hippoCallIconSecondary: UIColor { Self.parseOrDerived(hippoCallIconSecondaryHex, Self.staticColor("#5F6368")) }
    public var hippoCallIconSecondarySurface: UIColor { Self.parseOrDerived(hippoCallIconSecondarySurfaceHex, hippoReceiverSubtle3) }
    public var hippoCallIconMissed: UIColor { Self.parseOrDerived(hippoCallIconMissedHex, Self.staticColor("#E24C4B")) }
    public var hippoCallIconMissedSurface: UIColor { Self.parseOrDerived(hippoCallIconMissedSurfaceHex, Self.staticColor("#FBE4E6")) }

    // MARK: - Derived tokens (the "ladders") — not settable

    /// Accent ladder: accent blended over surface. Opaque steps that each state their own
    /// weight, not stacked translucency — stacking alpha over a 12% fill would composite to
    /// `α + 0.12(1 − α)`, not the ratio asked for.
    public var hippoAccentSubtle: UIColor { Self.blend(hippoAccent, hippoSurface, 0.12) }
    public var hippoAccentSubtle2: UIColor { Self.blend(hippoAccent, hippoSurface, 0.24) }
    public var hippoAccentSubtle3: UIColor { Self.blend(hippoAccent, hippoSurface, 0.32) }

    /// Receiver ladder: direction depends on the receiver colour. A light receiver has nowhere
    /// to lighten to, so its shades darken toward the text colour; a dark/saturated receiver
    /// lightens toward the surface using the accent ladder's exact ratios.
    public var hippoReceiverSubtle: UIColor { receiverShade(darkenRatio: 0.04, lightenRatio: 0.12) }
    public var hippoReceiverSubtle2: UIColor { receiverShade(darkenRatio: 0.08, lightenRatio: 0.24) }
    public var hippoReceiverSubtle3: UIColor { receiverShade(darkenRatio: 0.12, lightenRatio: 0.32) }

    /// A neutral card fill one step above the thread background but lighter than
    /// `hippoSurfaceInput` (which is tuned for text fields).
    public var hippoSurfaceSubtle: UIColor { Self.blend(hippoBorder, hippoSurface, 0.5) }

    private func receiverShade(darkenRatio: CGFloat, lightenRatio: CGFloat) -> UIColor {
        let receiver = hippoReceiver
        if Self.isLight(receiver) {
            return Self.blend(hippoTextPrimary, receiver, darkenRatio)
        }
        return Self.blend(receiver, hippoSurface, lightenRatio)
    }

    // MARK: - Calculation helpers

    /// Relative luminance test (ITU-R BT.709 weights), matching the Android token math 1:1:
    /// `0.2126 R + 0.7152 G + 0.0722 B > 127.5` (on a 0–255 scale).
    static func isLight(_ color: UIColor) -> Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > (127.5 / 255.0)
    }

    /// A single opaque step toward `fg`, blended over `bg` at `ratio` — a rung on a ladder.
    /// Alpha is intentionally dropped to 1.0: every ladder caller wants an opaque card/badge
    /// fill, never a translucent one.
    static func blend(_ fg: UIColor, _ bg: UIColor, _ ratio: CGFloat) -> UIColor {
        var fr: CGFloat = 0, fg2: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
        var br: CGFloat = 0, bg2: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        fg.getRed(&fr, green: &fg2, blue: &fb, alpha: &fa)
        bg.getRed(&br, green: &bg2, blue: &bb, alpha: &ba)
        return UIColor(
            red: fr * ratio + br * (1 - ratio),
            green: fg2 * ratio + bg2 * (1 - ratio),
            blue: fb * ratio + bb * (1 - ratio),
            alpha: 1.0
        )
    }

    // MARK: - Hex parsing (crash guard)

    /// Parses `value` as `#RRGGBB` or `#AARRGGBB` (alpha-first, matching Android's ARGB hex
    /// convention); falls back to `fallback` if `value` is nil, empty or malformed. Absorbs a
    /// bad integrator-supplied hex string the same way Android's `Color.parseColor` guard does.
    private static func parseOr(_ value: String?, _ fallback: String) -> UIColor {
        if let value = value, let color = uiColor(fromHex: value) {
            return color
        }
        return staticColor(fallback)
    }

    private static func parseOrDerived(_ value: String?, _ derived: UIColor) -> UIColor {
        if let value = value, let color = uiColor(fromHex: value) {
            return color
        }
        return derived
    }

    /// For hardcoded internal defaults that are known-valid hex — never user input.
    private static func staticColor(_ hex: String) -> UIColor {
        uiColor(fromHex: hex) ?? .gray
    }

    private static func uiColor(fromHex hex: String) -> UIColor? {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6 || cleaned.count == 8 else { return nil }

        var value: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&value) else { return nil }

        let hasAlpha = cleaned.count == 8
        let a = hasAlpha ? CGFloat((value >> 24) & 0xFF) / 255.0 : 1.0
        let r = CGFloat((value >> 16) & 0xFF) / 255.0
        let g = CGFloat((value >> 8) & 0xFF) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Builder

    /// Chainable setter API mirroring the Android `HippoColorConfig.Builder` method names 1:1,
    /// so the same palette reads the same way on both platforms:
    ///
    ///     let config = HippoColorConfig.Builder()
    ///         .hippoAccent("#3b5bdb")
    ///         .hippoReceiver("#ffffff")
    ///         .hippoSurfaceBackground("#eef1f5")
    ///         .build()
    ///     HippoConfig.shared.setCustomisedColorConfig(config)
    @objcMembers public class Builder: NSObject {
        private let config = HippoColorConfig()

        public override init() { super.init() }

        @discardableResult public func hippoSurface(_ hex: String) -> Builder { config.hippoSurfaceHex = hex; return self }
        @discardableResult public func hippoSurfaceBackground(_ hex: String) -> Builder { config.hippoSurfaceBackgroundHex = hex; return self }
        @discardableResult public func hippoSurfaceInput(_ hex: String) -> Builder { config.hippoSurfaceInputHex = hex; return self }
        @discardableResult public func hippoBorder(_ hex: String) -> Builder { config.hippoBorderHex = hex; return self }
        @discardableResult public func hippoTextPrimary(_ hex: String) -> Builder { config.hippoTextPrimaryHex = hex; return self }
        @discardableResult public func hippoTextMuted(_ hex: String) -> Builder { config.hippoTextMutedHex = hex; return self }
        @discardableResult public func hippoAccent(_ hex: String) -> Builder { config.hippoAccentHex = hex; return self }
        @discardableResult public func hippoOnAccent(_ hex: String) -> Builder { config.hippoOnAccentHex = hex; return self }
        @discardableResult public func hippoReceiver(_ hex: String) -> Builder { config.hippoReceiverHex = hex; return self }
        @discardableResult public func hippoError(_ hex: String) -> Builder { config.hippoErrorHex = hex; return self }
        @discardableResult public func hippoSuccess(_ hex: String) -> Builder { config.hippoSuccessHex = hex; return self }
        @discardableResult public func hippoWarning(_ hex: String) -> Builder { config.hippoWarningHex = hex; return self }
        @discardableResult public func hippoScrim(_ hex: String) -> Builder { config.hippoScrimHex = hex; return self }

        @discardableResult public func hippoIconPrimary(_ hex: String) -> Builder { config.hippoIconPrimaryHex = hex; return self }
        @discardableResult public func hippoIconPrimarySurface(_ hex: String) -> Builder { config.hippoIconPrimarySurfaceHex = hex; return self }
        @discardableResult public func hippoIconSecondary(_ hex: String) -> Builder { config.hippoIconSecondaryHex = hex; return self }
        @discardableResult public func hippoIconSecondarySurface(_ hex: String) -> Builder { config.hippoIconSecondarySurfaceHex = hex; return self }

        @discardableResult public func hippoCallIconPrimary(_ hex: String) -> Builder { config.hippoCallIconPrimaryHex = hex; return self }
        @discardableResult public func hippoCallIconPrimarySurface(_ hex: String) -> Builder { config.hippoCallIconPrimarySurfaceHex = hex; return self }
        @discardableResult public func hippoCallIconSecondary(_ hex: String) -> Builder { config.hippoCallIconSecondaryHex = hex; return self }
        @discardableResult public func hippoCallIconSecondarySurface(_ hex: String) -> Builder { config.hippoCallIconSecondarySurfaceHex = hex; return self }
        @discardableResult public func hippoCallIconMissed(_ hex: String) -> Builder { config.hippoCallIconMissedHex = hex; return self }
        @discardableResult public func hippoCallIconMissedSurface(_ hex: String) -> Builder { config.hippoCallIconMissedSurfaceHex = hex; return self }

        public func build() -> HippoColorConfig { config }
    }
}
