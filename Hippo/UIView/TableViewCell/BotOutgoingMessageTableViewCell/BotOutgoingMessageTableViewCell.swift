//
//  BotOutgoingMessageTableViewCell.swift
//  Hippo
//
//  Created by ANKUSH BHATIA on 26/04/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

protocol BotOtgoingMessageCellDelegate: class {
    func didTapQuickReply(atIndex index: Int, forCell cell: BotOutgoingMessageTableViewCell)
}

class BotOutgoingMessageTableViewCell: UITableViewCell {
    // MARK: Properties
    weak var delegate: BotOtgoingMessageCellDelegate?
    var buttons: [String] = []
    
    // MARK: IBOutlets
    @IBOutlet weak var shadowView: So_UIView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var collectionViewReply: UICollectionView!
    @IBOutlet weak var supportMessageTextView: UITextView!
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        supportMessageTextView.backgroundColor = .clear
        supportMessageTextView.textContainer.lineFragmentPadding = 0
        supportMessageTextView.textContainerInset = .zero
        collectionViewReply.register(UINib(nibName: "QuickReplyButtonCollectionViewCell", bundle: FuguFlowManager.bundle), forCellWithReuseIdentifier: String(describing: QuickReplyButtonCollectionViewCell.self))
        collectionViewReply.dataSource = self
        collectionViewReply.delegate = self
        collectionViewReply.flashScrollIndicators()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustShadow()
    }
    
    // MARK: Functions
    func setupBoxBackground(messageType: Int) {
        bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
    }
    
    func adjustShadow() {
        // shadowView.layoutIfNeeded()
        bgView.layoutIfNeeded()
        
        // shadowView.layer.cornerRadius = self.bgView.layer.cornerRadius
        
        // shadowView.backgroundColor = //UIColor.makeColor(red: 234, green: 234, blue: 234, alpha: 0.3)
        //self.shadowView.roundCorner(cornerRect: .allCorners, cornerRadius: self.shadowView.layer.cornerRadius)
    }
    
    func resetPropertiesOfSupportCell() {
        selectionStyle = .none
        supportMessageTextView.text = ""
        supportMessageTextView.attributedText = nil
        supportMessageTextView.isEditable = false
        supportMessageTextView.dataDetectorTypes = UIDataDetectorTypes.all
        supportMessageTextView.backgroundColor = .clear
        
        dateTimeLabel.text = ""
        dateTimeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        dateTimeLabel.textAlignment = .left
        dateTimeLabel.textColor = HippoConfig.shared.theme.incomingMsgDateTextColor
        
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = HippoConfig.shared.theme.incomingChatBoxColor
        bgView.layer.borderWidth = HippoConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = HippoConfig.shared.theme.chatBoxBorderColor.cgColor
        
        //        supportImageView.layer.cornerRadius = 4.0
        //        supportImageView.image = nil
        //        heightImageView.constant = 0
    }
    
    func configureCellOfSupportIncomingCell(resetProperties: Bool,attributedString: NSMutableAttributedString,channelId: Int,chatMessageObject: HippoMessage) -> BotOutgoingMessageTableViewCell {
        if resetProperties { resetPropertiesOfSupportCell() }
        
        let messageType = chatMessageObject.type.rawValue
        setupBoxBackground(messageType: messageType)
        
        
        let timeOfMessage = changeDateToParticularFormat(chatMessageObject.creationDateTime, dateFormat: "h:mm a", showInFormat: true)
        dateTimeLabel.text = "\t" + "\(timeOfMessage)"
        
//        supportMessageTextView.attributedText = attributedString
        self.buttons = chatMessageObject.content.buttonTitles
        
        if self.buttons.count > 0 {
            self.collectionViewReply.reloadData()
        }
        return self
    }
    
}

extension BotOutgoingMessageTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: QuickReplyButtonCollectionViewCell.self), for: indexPath) as? QuickReplyButtonCollectionViewCell else {
            fatalError()
        }
        cell.buttonCell.setTitle(self.buttons[indexPath.item], for: .normal)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: expectedWidth(buttonTitle: self.buttons[indexPath.item]), height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapQuickReply(atIndex: indexPath.item, forCell: self)
    }
    
    func expectedWidth(buttonTitle: String) -> CGFloat {
        let font = UIFont.regular(ofSize: 20)
        #if swift(>=4.0)
           let fontAttributes = [NSAttributedString.Key.font: font]
          let size = buttonTitle.size(withAttributes: fontAttributes)
        #else
          let fontAttributes = [NSFontAttributeName: font]
        let size = buttonTitle.size(attributes: fontAttributes)
        #endif
        
        var width = size.width
        width += 10 //Button leading and tralling
        
        return width
    }
}
