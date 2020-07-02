//
//  ChatInfoHeader.swift
//  Fugu
//
//  Created by Gagandeep Arora on 21/06/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit



class ChatInfoHeader: UIView {

    
    
    @IBOutlet weak var mainContentView: So_UIView!
    @IBOutlet weak var iconImageView: So_UIImageView!
    @IBOutlet weak var textLabel: So_CustomLabel!
    @IBOutlet weak var horizontalLineView: So_UIView!
    @IBOutlet weak var widthOfImageView: NSLayoutConstraint!
    @IBOutlet weak var constraintTextLabelLeading: NSLayoutConstraint!
    
    class func configureSectionHeader(headerInfo: ChatInfoCell) -> ChatInfoHeader {
        let chatInfoHeader = UINib(nibName: "ChatInfoHeader", bundle: FuguFlowManager.bundle).instantiate(withOwner: nil, options: nil)[0] as! ChatInfoHeader
        chatInfoHeader.textLabel.font = UIFont.bold(ofSize: 15.0)
        chatInfoHeader.textLabel.textColor = .black
        chatInfoHeader.textLabel.text = headerInfo.nameOfCell
        chatInfoHeader.iconImageView.image = headerInfo.infoImage ?? nil
        
        if chatInfoHeader.iconImageView.image == nil {
            chatInfoHeader.widthOfImageView.constant = 0
            chatInfoHeader.constraintTextLabelLeading.constant = 0
        } else {
            chatInfoHeader.widthOfImageView.constant = 20
            chatInfoHeader.constraintTextLabelLeading.constant = 8
        }
        
        return chatInfoHeader
    }

}
