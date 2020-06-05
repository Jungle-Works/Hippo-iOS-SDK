//
//  AssignedAgentTableViewCell.swift
//  SDKDemo1
//
//  Created by Vishal on 21/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit


class AssignedAgentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var view_Left : UIView!
    @IBOutlet weak var view_Right : UIView!
    @IBOutlet weak var view_Background : UIView!{
        didSet{
            view_Background.clipsToBounds = true
            view_Background.hippoCornerRadius = 8
        }
    }
    
    
    override func awakeFromNib() {
        resetPropertiesAssignedAgentCell()
    }
    
    
    internal func resetPropertiesAssignedAgentCell() {
        backgroundColor = .clear
        clipsToBounds = true
        selectionStyle = .none
        messageLabel.font = UIFont(name:"HelveticaNeue", size: 12.0)
    }
    
    func setupCell(reset: Bool = true, message: HippoMessage) {
        if reset {
            resetPropertiesAssignedAgentCell()
        }
        
        messageLabel.text = message.message
    }
    
    func set(card: PaymentHeader) {
        view_Left.isHidden = true
        view_Right.isHidden = true
        view_Background.backgroundColor = .white
        messageLabel.text = card.text
        messageLabel.font = UIFont.boldSystemFont(ofSize: 15)
        messageLabel.textColor = .black//HippoConfig.shared.theme.darkThemeTextColor
        //messageContainer.hippoCornerRadius = messageContainer.bounds.size.height / 2
        //messageContainer.layer.borderWidth = 1
        //messageContainer.layer.borderColor = UIColor.lightGray.cgColor
    }
}
extension UIView{
    func roundedView(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
            byRoundingCorners: [.topLeft , .topRight],
            cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}
