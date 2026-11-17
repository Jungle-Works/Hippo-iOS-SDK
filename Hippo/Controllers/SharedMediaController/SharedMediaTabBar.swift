//
//  SharedMediaTabBar.swift
//  Hippo
//
//  Two-segment Media/Docs switch for the Shared Media screen: a grey track with a
//  white pill that slides under the selected title. Built in code rather than as a
//  UISegmentedControl because the track/pill radii and the selected-weight change
//  aren't reachable through that API on iOS 15.
//

import UIKit

final class SharedMediaTabBar: UIView {

    // MARK: Metrics
    //
    // Measured off the design: a 42pt track with a 4pt inset pill.

    static let preferredHeight: CGFloat = 42
    private static let pillInset: CGFloat = 4
    private static let trackCornerRadius: CGFloat = 12
    private static let pillCornerRadius: CGFloat = 10
    private static let titleFontSize: CGFloat = 15

    // MARK: Callbacks

    /// Fired only when the selection actually changes, so the caller doesn't reload
    /// for a tap on the already-selected tab.
    var onSelect: ((SharedMediaTab) -> Void)?

    // MARK: State

    private(set) var selectedTab: SharedMediaTab = .media

    // MARK: Subviews

    private let pill = UIView()
    private let mediaButton = UIButton(type: .custom)
    private let docsButton = UIButton(type: .custom)

    private var buttons: [UIButton] { [mediaButton, docsButton] }

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let colorConfig = HippoConfig.shared.colorConfig

        backgroundColor = colorConfig.hippoSurfaceInput
        layer.cornerRadius = Self.trackCornerRadius
        layer.masksToBounds = true

        pill.backgroundColor = colorConfig.hippoSurface
        pill.layer.cornerRadius = Self.pillCornerRadius
        pill.isUserInteractionEnabled = false
        addSubview(pill)

        mediaButton.setTitle(HippoStrings.sharedMediaTabMedia, for: .normal)
        docsButton.setTitle(HippoStrings.sharedMediaTabDocs, for: .normal)

        mediaButton.addTarget(self, action: #selector(mediaTapped), for: .touchUpInside)
        docsButton.addTarget(self, action: #selector(docsTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        applyTitleStyles()
        isAccessibilityElement = false
    }

    // MARK: Layout

    // The pill is positioned by frame rather than constraints so the slide is a
    // single frame animation and doesn't fight the stack view's own layout pass.
    override func layoutSubviews() {
        super.layoutSubviews()
        pill.frame = pillFrame(for: selectedTab)
    }

    private func pillFrame(for tab: SharedMediaTab) -> CGRect {
        let inset = Self.pillInset
        let width = (bounds.width - inset * 2) / 2
        let x = tab == .media ? inset : inset + width
        return CGRect(x: x, y: inset, width: width, height: bounds.height - inset * 2)
    }

    // MARK: Selection

    func select(_ tab: SharedMediaTab, animated: Bool) {
        guard tab != selectedTab else { return }
        selectedTab = tab

        let apply = {
            self.pill.frame = self.pillFrame(for: tab)
            self.applyTitleStyles()
        }

        guard animated else {
            apply()
            return
        }
        UIView.animate(withDuration: 0.22,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState],
                       animations: apply)
    }

    private func applyTitleStyles() {
        let colorConfig = HippoConfig.shared.colorConfig
        let pairs: [(UIButton, Bool)] = [
            (mediaButton, selectedTab == .media),
            (docsButton, selectedTab == .docs)
        ]
        for (button, isSelected) in pairs {
            button.setTitleColor(isSelected ? colorConfig.hippoTextPrimary
                                            : colorConfig.hippoTextMuted,
                                 for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: Self.titleFontSize,
                                                  weight: isSelected ? .semibold : .regular)
            button.accessibilityTraits = isSelected ? [.button, .selected] : [.button]
        }
    }

    @objc private func mediaTapped() {
        handleTap(.media)
    }

    @objc private func docsTapped() {
        handleTap(.docs)
    }

    private func handleTap(_ tab: SharedMediaTab) {
        guard tab != selectedTab else { return }
        select(tab, animated: true)
        onSelect?(tab)
    }
}
