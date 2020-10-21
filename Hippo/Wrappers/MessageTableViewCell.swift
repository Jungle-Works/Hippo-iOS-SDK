//
//  MessageTableViewCell.swift
//  Hippo
//
//  Created by Vishal on 12/08/19.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    var message: HippoMessage?
    var isIncomingView: Bool = false
    
    @IBOutlet weak var sourceIcon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var senderImageView: UIImageView!
    
    @IBOutlet weak var senderImageTraillingConstaints: NSLayoutConstraint!
    @IBOutlet weak var senderImageWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func getTimeString() -> String {
        guard message != nil else {
            return ""
        }
        let timeOfMessage = changeDateToParticularFormat(message!.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        return timeOfMessage
    }
    func setTime() {
        let timeOfMessage = getTimeString()
        timeLabel.text = message?.messageState == MessageState.MessageEdited ? "(\(HippoStrings.edited)) " + timeOfMessage : timeOfMessage
    }
    func intalizeCell(with message: HippoMessage, isIncomingView: Bool) {
        self.message?.messageRefresed = nil
        self.message = message
        self.isIncomingView = isIncomingView
        setSourceIcon()
        
        
        self.message?.messageRefresed = {
            DispatchQueue.main.async {
                self.setSenderImageView()
            }
        }
        setSenderImageView()
    }
    internal func setSourceIcon() {
        let showMessageSourceIcon = HippoConfig.shared.appUserType == .agent ? true : HippoProperty.current.showMessageSourceIcon
        let icon =  showMessageSourceIcon ? message?.messageSource.getIcon() :  nil
        sourceIcon?.image = icon
        sourceIcon?.isHidden = icon == nil
        sourceIcon?.tintColor = HippoConfig.shared.theme.sourceIconColor
    }
    
    func setSenderImageView() {
        guard let message = self.message, isIncomingView, message.chatType.isImageViewAllowed else {
            hideSenderImageView()
            return
        }
        showSenderImageView()
        
//        let isMessageAllowedForImage = message.type == .consent
//
//        if message.belowMessageUserId == message.senderId && !isMessageAllowedForImage {
//            unsetImageInSender()
//        } else if let senderImage = message.senderImage, let url = URL(string: senderImage) {
//            setImageInSenderView(imageURL: url)
//        } else {
//            setNameAsTitle(message.senderFullName)
//        }
        
        let isMessageAllowedForImage = message.type == .consent  || message.belowMessageType == .card || message.belowMessageType == .paymentCard || message.aboveMessageType == .consent
        
        if (message.aboveMessageUserId == message.senderId && !isMessageAllowedForImage) {
            unsetImageInSender()
        } else {
//            if let senderImage = message.senderImage, let url = URL(string: senderImage) {
//                setImageInSenderView(imageURL: url)
//            }else{
//                setNameAsTitle(message.senderFullName)
//            }
            if HippoConfig.shared.appUserType == .agent{
                if let senderImage = message.senderImage, senderImage.isEmpty == false, senderImage.contains("http"), let url = URL(string: senderImage) {
                    setImageInSenderView(imageURL: url)
                }else{
                    setNameAsTitle(message.senderFullName)
                }
            }else{
                if let senderImage = message.senderImage, let url = URL(string: senderImage) {
                    setImageInSenderView(imageURL: url)
                }else{
                    setNameAsTitle(message.senderFullName)
                }
            }
        }
        
    }
    
    func hideSenderImageView() {
        senderImageView?.image = nil
        senderImageView?.isHidden = true
        senderImageWidthConstraint?.constant = 0
        senderImageTraillingConstaints?.constant = 0
        layoutIfNeeded()
    }
    
    func showSenderImageView() {
        senderImageView.isHidden = false
        senderImageWidthConstraint.constant = 30
        senderImageTraillingConstaints.constant = 5
        senderImageView.layer.cornerRadius = 6//senderImageView.bounds.height
        senderImageView.layer.masksToBounds = true
        layoutIfNeeded()
    }
    
//    func setImageInSenderView(imageURL: URL?) {
//        senderImageView.kf.setImage(with: imageURL, placeholder: HippoConfig.shared.theme.placeHolderImage,  completionHandler: {(_, error, _, _) in
//            guard let parsedError = error else {
//                return
//            }
//            print(parsedError.localizedDescription)
//        })
//    }
//
//    func setNameAsTitle(_ name: String?) {
//        if let parsedName = name {
////            self.senderImageView.setImage(string: parsedName, color: UIColor.lightGray, circular: true)
//            self.senderImageView.image = UIImage(named: parsedName)
//        } else {
//            self.senderImageView.image = HippoConfig.shared.theme.placeHolderImage
//        }
//    }
//
//    func unsetImageInSender() {
//        senderImageView.image = nil
//    }
    
    func setImageInSenderView(imageURL: URL?) {
        senderImageView.contentMode = .scaleAspectFill
        senderImageView.kf.setImage(with: imageURL, placeholder: HippoConfig.shared.theme.placeHolderImage,  completionHandler: {(_, error, _, _) in
            guard let parsedError = error else {
                return
            }
            print(parsedError.localizedDescription)
        })
    }
    
    func setNameAsTitle(_ name: String?) {
        if let parsedName = name {
            self.senderImageView.setTextInImage(string: parsedName, color: UIColor.lightGray, circular: false)
        } else {
            self.senderImageView.image = HippoConfig.shared.theme.placeHolderImage
        }
    }
    
    func unsetImageInSender() {
        senderImageView.image = nil
    }
}
