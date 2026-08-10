//
//  SelectionBottomSheetViewController.swift
//  Hippo
//
//  Created by Harpreet-singh on 28/07/26.
//  Copyright © 2026 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class SelectionBottomSheetViewController: UIViewController {

    private let titleText: String
    private let options: [String]
    private let selected: String?
    private let onSelect: (String) -> Void

    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private init(title: String, options: [String], selected: String?, onSelect: @escaping (String) -> Void) {
        self.titleText = title
        self.options = options
        self.selected = selected
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func present(
        from presenter: UIViewController,
        title: String,
        options: [String],
        selected: String?,
        onSelect: @escaping (String) -> Void
    ) {
        let sheet = SelectionBottomSheetViewController(title: title, options: options, selected: selected, onSelect: onSelect)
        sheet.modalPresentationStyle = .pageSheet
        if let sheetController = sheet.sheetPresentationController {
            sheetController.detents = [.medium(), .large()]
            sheetController.prefersGrabberVisible = true
        }
        presenter.present(sheet, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTitleBar()
        setUpTableView()
    }

    private func setUpTitleBar() {
        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .secondaryLabel
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -12),

            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(SelectionOptionCell.self, forCellReuseIdentifier: "SelectionBottomSheetCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func closeButtonPressed() {
        dismiss(animated: true)
    }
}

extension SelectionBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionBottomSheetCell", for: indexPath) as? SelectionOptionCell else {
            return UITableViewCell()
        }
        let option = options[indexPath.row]
        cell.configure(text: option, isSelected: option == selected, tintColor: HippoConfig.shared.theme.themeColor)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = options[indexPath.row]
        dismiss(animated: true) { [onSelect] in
            onSelect(option)
        }
    }
}

private class SelectionOptionCell: UITableViewCell {

    private let highlightView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        highlightView.layer.cornerRadius = 10
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(highlightView)

        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.font = .systemFont(ofSize: 16)

        guard let textLabel else { return }

        NSLayoutConstraint.activate([
            highlightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            highlightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            highlightView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            highlightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            textLabel.leadingAnchor.constraint(equalTo: highlightView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: highlightView.trailingAnchor, constant: -12),
            textLabel.centerYAnchor.constraint(equalTo: highlightView.centerYAnchor),
            textLabel.topAnchor.constraint(equalTo: highlightView.topAnchor, constant: 10),
            textLabel.bottomAnchor.constraint(equalTo: highlightView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, isSelected: Bool, tintColor: UIColor) {
        textLabel?.text = text
        if isSelected {
            highlightView.backgroundColor = tintColor.withAlphaComponent(0.12)
            textLabel?.textColor = tintColor
        } else {
            highlightView.backgroundColor = .clear
            textLabel?.textColor = .label
        }
    }
}
