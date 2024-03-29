//
//  DocumentRecivedTableViewCell.swift
//  OfficeChat
//
//  Created by Asim on 22/03/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit

class IncomingDocumentTableViewCell: DocumentTableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet var constraintHeightTextView : NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
      super.awakeFromNib()
      
//      addTapGestureInNameLabel()
   }
    
    func setCellWith(message: HippoMessage) {
        
        setUIAccordingToTheme()
        intalizeCell(with: message, isIncomingView: true)
        self.message = message
        
        
        updateUI()
        
        if message.message != "" {
            constraintHeightTextView.isActive = false
            textView.text = message.message
        }else {
            constraintHeightTextView.isActive = true
        }
    }
    
    func setUIAccordingToTheme() {
        timeLabel.text = ""
        timeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        timeLabel.textAlignment = .left
        timeLabel.textColor = HippoConfig.shared.theme.dateTimeTextColor
        
        bgView.layer.cornerRadius = HippoConfig.shared.theme.chatBoxCornerRadius
        bgView.backgroundColor = HippoConfig.shared.theme.recievingBubbleColor
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
        nameLabel.font = HippoConfig.shared.theme.senderNameFont
        nameLabel.textColor = HippoConfig.shared.theme.senderNameColor
        
        fileSizeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        fileSizeLabel.textColor = HippoConfig.shared.theme.dateTimeTextColor
        
        docName.font = HippoConfig.shared.theme.incomingMsgFont
        docName.textColor = HippoConfig.shared.theme.incomingMsgColor
        
        
        retryButton.tintColor = HippoConfig.shared.theme.incomingMsgColor
        docImage.tintColor = HippoConfig.shared.theme.incomingMsgColor
        activityIndicator.tintColor = HippoConfig.shared.theme.incomingMsgColor
        activityIndicator.color = HippoConfig.shared.theme.incomingMsgColor
    }
   
   func addTapGestureInNameLabel() {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
      nameLabel.addGestureRecognizer(tapGesture)
   }
   
   @objc func nameTapped() {
//      if let msg = message {
//         interactionDelegate?.nameOnMessageTapped(msg)
//      }
   }
    
    
}
