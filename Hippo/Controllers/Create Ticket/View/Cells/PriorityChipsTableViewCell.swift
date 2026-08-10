//
//  PriorityChipsTableViewCell.swift
//  Hippo
//

import UIKit

class PriorityChipsTableViewCell: UITableViewCell {

    var priorities: [String] = ["Low", "Medium", "High", "Urgent"] {
        didSet { rebuildChips() }
    }

    var selectedPriority: String = "" {
        didSet { updateChipStates() }
    }

    var callBack: ((String) -> ())?

    private func dotColor(for priority: String) -> UIColor {
        switch priority.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "normal":
            return UIColor(red: 0x4C / 255, green: 0xAF / 255, blue: 0x50 / 255, alpha: 1)
        case "critical":
            return UIColor(red: 0xFF / 255, green: 0xC1 / 255, blue: 0x07 / 255, alpha: 1)
        case "urgent":
            return UIColor(red: 0xF4 / 255, green: 0x43 / 255, blue: 0x36 / 255, alpha: 1)
        default:
            return UIColor(red: 0x9E / 255, green: 0x9E / 255, blue: 0x9E / 255, alpha: 1)
        }
    }

    private let selectedBgColor = UIColor(red: 0.10, green: 0.18, blue: 0.50, alpha: 1)

    private var chipButtons: [UIButton] = []

    private let fieldLabel: UILabel = {
        let l = UILabel()
        l.styleAsFieldLabel()
        l.setFieldTitle("Priority", isRequired: true)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fill
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let errorLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor.systemRed
        l.numberOfLines = 0
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var errorLabelHeightConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = UIColor(red: 0.97254902119999997, green: 0.97647058959999999, blue: 0.98039215690000003, alpha: 1)
        contentView.addSubview(fieldLabel)
        contentView.addSubview(stackView)
        contentView.addSubview(errorLabel)

        errorLabelHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            fieldLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            fieldLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fieldLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            stackView.topAnchor.constraint(equalTo: fieldLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 34),

            errorLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            errorLabelHeightConstraint,
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])

        rebuildChips()
    }

    private func rebuildChips() {
        chipButtons.forEach { $0.removeFromSuperview() }
        chipButtons.removeAll()

        for (index, title) in priorities.enumerated() {
            let color = dotColor(for: title)
            let btn = makeChip(title: title, dotColor: color, tag: index)
            chipButtons.append(btn)
            stackView.addArrangedSubview(btn)
        }

        updateChipStates()
    }

    private func makeChip(title: String, dotColor: UIColor, tag: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tag = tag
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 14)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)

        let normalDot = circleDotImage(color: dotColor, size: 8)
        let selectedDot = circleDotImage(color: .white, size: 8)
        btn.setImage(normalDot, for: .normal)
        btn.setImage(selectedDot, for: .selected)
        btn.setTitle(title, for: .normal)
        btn.setTitle(title, for: .selected)

        return btn
    }

    @objc private func chipTapped(_ sender: UIButton) {
        selectedPriority = priorities[sender.tag]
        callBack?(selectedPriority)
        setError(nil)
    }

    func setError(_ message: String?) {
        errorLabel.text = message
        let hasError = !(message ?? "").isEmpty
        errorLabel.isHidden = !hasError
        errorLabelHeightConstraint.constant = hasError ? 16 : 0
    }

    private func updateChipStates() {
        for (index, btn) in chipButtons.enumerated() {
            let isSelected = !selectedPriority.isEmpty &&
                priorities[index].lowercased() == selectedPriority.lowercased()
            btn.isSelected = isSelected
            if isSelected {
                btn.backgroundColor = selectedBgColor
                btn.layer.borderColor = selectedBgColor.cgColor
                btn.setTitleColor(.white, for: .selected)
            } else {
                btn.backgroundColor = .white
                btn.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1).cgColor
                btn.setTitleColor(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1), for: .normal)
            }
        }
    }

    private func circleDotImage(color: UIColor, size: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        return (UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()).withRenderingMode(.alwaysOriginal)
    }
}
