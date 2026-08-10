//
//  UILabel+FieldLabel.swift
//  Hippo
//

import UIKit

extension UILabel {
    func styleAsFieldLabel(fontSize: CGFloat = 14) {
        font = .systemFont(ofSize: fontSize, weight: .medium)
        textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    }

    func setFieldTitle(_ title: String, isRequired: Bool) {
        guard isRequired else {
            text = title
            return
        }
        let fullText = "\(title) *"
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [.foregroundColor: textColor as Any])
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: (fullText as NSString).range(of: "*"))
        attributedText = attributedString
    }
}
