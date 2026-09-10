//
//  OptionsBottomSheetViewController.swift
//  Hippo
//
//  A generic bottom sheet that presents a vertical list of tappable options
//  (icon + title). Built on the native UISheetPresentationController so the
//  grabber, rounded corners and swipe / tap-outside-to-dismiss come for free.
//
//  Usage:
//      OptionsBottomSheetViewController.present(
//          from: self,
//          title: "Please select an option",
//          options: [
//              BottomSheetOption(icon: someImage, title: "Shared Media") { ... }
//          ]
//      )
//

import UIKit

struct BottomSheetOption {
    let icon: UIImage?
    let title: String
    let handler: () -> Void

    init(icon: UIImage? = nil, title: String, handler: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.handler = handler
    }
}

final class OptionsBottomSheetViewController: UIViewController {

    private let sheetTitle: String?
    private let options: [BottomSheetOption]

    private let rowHeight: CGFloat = 56
    private let titleAreaHeight: CGFloat = 52

    // MARK: - Subviews

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = sheetTitle
        label.font = UIFont.bold(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.isScrollEnabled = false
        table.rowHeight = rowHeight
        let hasAnyIcon = options.contains { $0.icon != nil }
        table.separatorInset = UIEdgeInsets(top: 0, left: hasAnyIcon ? 58 : 0, bottom: 0, right: 0)
        table.backgroundColor = .clear
        table.tableFooterView = UIView()
        table.register(OptionBottomSheetCell.self, forCellReuseIdentifier: OptionBottomSheetCell.reuseID)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Init

    private init(title: String?, options: [BottomSheetOption]) {
        self.sheetTitle = title
        self.options = options
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Presentation

    static func present(from presenter: UIViewController,
                        title: String?,
                        options: [BottomSheetOption]) {
        guard !options.isEmpty else { return }

        let sheet = OptionsBottomSheetViewController(title: title, options: options)
        sheet.modalPresentationStyle = .pageSheet

        if let controller = sheet.sheetPresentationController {
            controller.prefersGrabberVisible = true
            controller.preferredCornerRadius = 16
            let contentHeight = sheet.contentHeight
            if #available(iOS 16.0, *) {
                controller.detents = [.custom { _ in contentHeight }]
            } else {
                controller.detents = [.medium()]
            }
        }
        presenter.present(sheet, animated: true)
    }

    private var contentHeight: CGFloat {
        let hasTitle = (sheetTitle?.isEmpty == false)
        let titlePart = hasTitle ? titleAreaHeight : 8
        return titlePart + CGFloat(options.count) * rowHeight
            + UIView.safeAreaInsetOfKeyWindow.bottom + 12
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let hasTitle = (sheetTitle?.isEmpty == false)
        if hasTitle {
            view.addSubview(titleLabel)
        }
        view.addSubview(tableView)

        var constraints: [NSLayoutConstraint] = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        if hasTitle {
            constraints += [
                titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14)
            ]
        } else {
            constraints.append(tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8))
        }

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension OptionsBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OptionBottomSheetCell.reuseID, for: indexPath) as! OptionBottomSheetCell
        cell.configure(with: options[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let option = options[indexPath.row]
        dismiss(animated: true) {
            option.handler()
        }
    }
}

// MARK: - Cell

private final class OptionBottomSheetCell: UITableViewCell {

    static let reuseID = "OptionBottomSheetCell"

    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = HippoConfig.shared.theme.themeColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regular(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var titleLeadingWithIcon: NSLayoutConstraint!
    private var titleLeadingCentered: NSLayoutConstraint!
    private var titleCenterX: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .default

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)

        // With an icon: title sits left, after the icon.
        titleLeadingWithIcon = titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16)
        // Without an icon: title is centered in the row.
        titleLeadingCentered = titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20)
        titleCenterX = titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with option: BottomSheetOption) {
        titleLabel.text = option.title
        if let icon = option.icon {
            iconView.image = icon.withRenderingMode(.alwaysTemplate)
            iconView.isHidden = false
            titleLabel.textAlignment = .natural
            titleLeadingCentered.isActive = false
            titleCenterX.isActive = false
            titleLeadingWithIcon.isActive = true
        } else {
            iconView.image = nil
            iconView.isHidden = true
            titleLabel.textAlignment = .center
            titleLeadingWithIcon.isActive = false
            titleLeadingCentered.isActive = true
            titleCenterX.isActive = true
        }
    }
}
