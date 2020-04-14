//
//  InformationView.swift
//  HippoChat
//
//  Created by Vishal on 29/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit
protocol InformationViewDelegate: class {
    
}

class InformationView: UIView {
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var informationImageView: UIImageView!
    @IBOutlet weak var informationLabel: UILabel!
    
    weak var delegate: InformationViewDelegate?
    
    
    internal func setTheme() {
        mainContainer.backgroundColor = .clear
        
        informationLabel.textColor = UIColor.lightGray
        informationLabel.text = "No Conversation found"
    }
    
    class func loadView(_ frame: CGRect, delegate: InformationViewDelegate) -> InformationView {
        let array = FuguFlowManager.bundle?.loadNibNamed("InformationView", owner: self, options: nil)
        let view: InformationView? = array?.first as? InformationView
        view?.frame = frame
        guard let customView = view else {
            return InformationView()
        }
        customView.delegate = delegate
        customView.setTheme()
        return customView
    }
}
