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
}
