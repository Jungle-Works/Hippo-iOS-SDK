//
//  NavigationBar.swift
//  Hippo
//
//  Created by Arohi Sharma on 22/05/20.
//

import Foundation
import UIKit

final class NavigationBar: UIView {
    
    private static let NIB_NAME = "NavigationBar"
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var image_back : UIImageView!
    @IBOutlet weak var rightSwitchButtonContainerView: UIView!
    @IBOutlet weak var rightSwitchButton: UISwitch!
    
    var title: String = "" {
        didSet {
            image_back.tintColor = HippoConfig.shared.theme.titleTextColor
            image_back.image = HippoConfig.shared.theme.leftBarButtonImage
            titleLabel.font = HippoConfig.shared.theme.headerTextFont
            titleLabel.textColor = HippoConfig.shared.theme.headerTextColor
            titleLabel.text = HippoConfig.shared.theme.headerText
        }
    }
    
    var isLeftButtonHidden: Bool {
        set {
            leftButton.isHidden = newValue
        }
        get {
            return leftButton.isHidden
        }
    }
    
    override func awakeFromNib() {
        initWithNib()
    }
    
    private func initWithNib() {
        FuguFlowManager.bundle?.loadNibNamed(NavigationBar.NIB_NAME, owner: self, options: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
}

