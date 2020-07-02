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
    @IBOutlet weak var button_Info : UIButton!{
        didSet{
            button_Info.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var constraint_TopBtn : NSLayoutConstraint!
    @IBOutlet weak var constraint_BtnHeight : NSLayoutConstraint!
    
    
    weak var delegate: InformationViewDelegate?
      
    var isButtonInfoHidden : Bool?{
        didSet{
            if isButtonInfoHidden ?? false{
                constraint_TopBtn.constant = 0
                constraint_BtnHeight.constant = 0
                button_Info.isHidden = true
            }else{
                constraint_TopBtn.constant = 30
                constraint_BtnHeight.constant = 40
                button_Info.isHidden = false
            }
        }
    }
    
    
    internal func setTheme() {
        mainContainer.backgroundColor = .clear
        informationLabel.font = UIFont.regular(ofSize: 17)
        informationLabel.textColor = UIColor(red: 143/255, green: 147/255, blue: 152/255, alpha: 1.0)//UIColor.lightGray
        informationLabel.text = "No Conversation found"
        informationLabel.textAlignment = .center
        button_Info.isHidden = true
        button_Info.backgroundColor = HippoConfig.shared.theme.themeColor
        button_Info.titleLabel?.font = UIFont.bold(ofSize: 15)//UIFont.boldSystemFont(ofSize: 15.0)
        button_Info.setTitleColor(.white, for: .normal)
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
    
    @IBAction func button_Action(){
        HippoConfig.shared.delegate?.chatListButtonAction()
    }
    
}
