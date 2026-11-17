//
//  SharedMediaDocCell.swift
//  Hippo
//
//  Row for the Docs tab of the Shared Media screen: file icon with a dynamic
//  extension badge, title, metadata subtitle, and a download affordance.
//
//  Built in code rather than as a xib because the badge overlaps the icon and the
//  only per-type asset needed is the shared DocBaseImage — there is nothing here a
//  nib would express more clearly, and it keeps the extension list open-ended.
//

import UIKit

final class SharedMediaDocCell: UICollectionViewCell {

    static let reuseIdentifier = "SharedMediaDocCell"
    static let preferredHeight: CGFloat = 72

    // MARK: Metrics

    private enum Metrics {
        static let horizontalInset: CGFloat = 16
        static let iconWidth: CGFloat = 40
        /// DocBaseImage is 240x264, so 40x44 keeps its aspect exactly.
        static let iconHeight: CGFloat = 44
        static let iconToText: CGFloat = 12
        static let accessorySize: CGFloat = 24
        static let badgeHeight: CGFloat = 14
        static let badgeCornerRadius: CGFloat = 3
        static let badgeHorizontalPadding: CGFloat = 4
        static let badgeFontSize: CGFloat = 8
        static let titleFontSize: CGFloat = 15
        static let subtitleFontSize: CGFloat = 12
    }

    // MARK: Subviews

    private let iconView = UIImageView()
    private let badgeLabel = PaddedLabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let downloadButton = UIButton(type: .custom)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let separator = UIView()

    /// Fired on the download glyph. The whole row is tappable too (handled by the
    /// collection view), so this is only a shortcut to the same action.
    private var onDownload: (() -> Void)?

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
        contentView.backgroundColor = colorConfig.hippoSurface

        iconView.image = UIImage(named: "DocBaseImage",
                                 in: FuguFlowManager.bundle,
                                 compatibleWith: nil)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        badgeLabel.backgroundColor = colorConfig.hippoAccent
        badgeLabel.textColor = colorConfig.hippoOnAccent
        badgeLabel.font = .systemFont(ofSize: Metrics.badgeFontSize, weight: .bold)
        badgeLabel.textAlignment = .center
        badgeLabel.horizontalPadding = Metrics.badgeHorizontalPadding
        badgeLabel.layer.cornerRadius = Metrics.badgeCornerRadius
        badgeLabel.layer.masksToBounds = true
        badgeLabel.adjustsFontSizeToFitWidth = true
        badgeLabel.minimumScaleFactor = 0.7
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: Metrics.titleFontSize, weight: .medium)
        titleLabel.textColor = colorConfig.hippoTextPrimary
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = .systemFont(ofSize: Metrics.subtitleFontSize, weight: .regular)
        subtitleLabel.textColor = colorConfig.hippoTextMuted
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        downloadButton.setImage(UIImage(named: "downloadIcon",
                                        in: FuguFlowManager.bundle,
                                        compatibleWith: nil)?
                                    .withRenderingMode(.alwaysTemplate),
                                for: .normal)
        downloadButton.tintColor = colorConfig.hippoTextMuted
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false

        spinner.hidesWhenStopped = true
        spinner.color = colorConfig.hippoTextMuted
        spinner.translatesAutoresizingMaskIntoConstraints = false

        separator.backgroundColor = colorConfig.hippoBorder
        separator.translatesAutoresizingMaskIntoConstraints = false

        [iconView, badgeLabel, titleLabel, subtitleLabel, downloadButton, spinner, separator]
            .forEach(contentView.addSubview)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                              constant: Metrics.horizontalInset),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: Metrics.iconWidth),
            iconView.heightAnchor.constraint(equalToConstant: Metrics.iconHeight),

            // Sits across the lower-left corner of the page glyph, as in the design.
            badgeLabel.leadingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -2),
            badgeLabel.bottomAnchor.constraint(equalTo: iconView.bottomAnchor, constant: -6),
            badgeLabel.heightAnchor.constraint(equalToConstant: Metrics.badgeHeight),
            badgeLabel.trailingAnchor.constraint(lessThanOrEqualTo: iconView.trailingAnchor),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor,
                                               constant: Metrics.iconToText),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: downloadButton.leadingAnchor,
                                                constant: -Metrics.iconToText),

            downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                     constant: -Metrics.horizontalInset),
            downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: Metrics.accessorySize),
            downloadButton.heightAnchor.constraint(equalToConstant: Metrics.accessorySize),

            spinner.centerXAnchor.constraint(equalTo: downloadButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor),

            separator.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onDownload = nil
        spinner.stopAnimating()
        downloadButton.isHidden = false
    }

    // MARK: Configuration

    func configure(with item: ShareMediaModel,
                   isLastRow: Bool,
                   onDownload: @escaping () -> Void) {
        self.onDownload = onDownload

        titleLabel.text = item.displayTitle
        subtitleLabel.text = item.displaySubtitle()

        let badgeText = item.fileExtension
        badgeLabel.text = badgeText
        badgeLabel.isHidden = badgeText == nil

        separator.isHidden = isLastRow

        accessibilityLabel = [item.displayTitle, item.displaySubtitle()]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        updateDownloadState(for: item.url)
    }

    /// Three states: already local (no affordance), in flight (spinner), or
    /// downloadable (the arrow).
    func updateDownloadState(for url: String?) {
        guard let url = url else {
            downloadButton.isHidden = true
            spinner.stopAnimating()
            return
        }

        if DownloadManager.shared.isFileDownloadedWith(url: url) {
            downloadButton.isHidden = true
            spinner.stopAnimating()
        } else if DownloadManager.shared.isFileBeingDownloadedWith(url: url) {
            downloadButton.isHidden = true
            spinner.startAnimating()
        } else {
            downloadButton.isHidden = false
            spinner.stopAnimating()
        }
    }

    @objc private func downloadTapped() {
        onDownload?()
    }
}

// MARK: - Padded label

/// UILabel with horizontal padding, so the extension badge doesn't need a wrapper
/// view just to inset its text.
private final class PaddedLabel: UILabel {

    var horizontalPadding: CGFloat = 0

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += horizontalPadding * 2
        return size
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: horizontalPadding,
                                  bottom: 0, right: horizontalPadding)
        super.drawText(in: rect.inset(by: insets))
    }
}
