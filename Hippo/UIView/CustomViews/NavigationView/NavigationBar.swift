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
    @IBOutlet weak var constraint_RightWidth : NSLayoutConstraint!
    
    
    
    var setupNavigationBar : (()->())?
    var title: String = "" {
        didSet {
            titleLabel.font = HippoConfig.shared.theme.headerTextFont
            titleLabel.textColor = HippoConfig.shared.theme.headerTextColor
            titleLabel.text = title
        }
    }
    
    var isLeftButtonHidden: Bool {
        set {
            leftButton.isHidden = newValue
            image_back.isHidden = newValue
        }
        get {
            return leftButton.isHidden
        }
    }
    
    override func awakeFromNib() {
        initWithNib()
    }
    
    func initMethod(){
        initWithNib()
    }
    
    private func setup(){
        image_back.tintColor = HippoConfig.shared.theme.headerTextColor
        image_back.image = HippoConfig.shared.theme.leftBarButtonImage
    }
    
    
    private func initWithNib() {
        if self.subviews.contains(view ?? UIView()){
            self.view.removeFromSuperview()
        }
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
        self.setup()
        self.setupNavigationBar?()
    }
}

