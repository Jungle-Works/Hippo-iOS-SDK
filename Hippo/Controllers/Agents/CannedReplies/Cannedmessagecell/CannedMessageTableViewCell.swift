////
////  CannedMessageTableViewCell.swift
////  Hippo
////
////  Created by Neha Vaish on 19/02/24.
////
//
//import UIKit
//
//class CannedMessageTableViewCell: CoreTabelViewCell {
//
//    @IBOutlet weak var mainContentView: UIView!
//    @IBOutlet weak var titleLabel: So_CustomLabel!
//    @IBOutlet weak var descriptionLabel: So_CustomLabel!
//    @IBOutlet weak var horizontalLine: UIView!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//}
//
//extension CannedMessageTableViewCell {
//    func resetPropertiesOfCannedMessage() {
//        clipsToBounds = true
//        setTheme()
////        backgroundColor = .clear
////        accessoryType = .disclosureIndicator
//        //horizontalLine.isHidden = true
//    }
//
//    func configureCannedMessageCell(resetProperties: Bool, cannedObject: CannedReply) -> CannedMessageTableViewCell {
//        if resetProperties == true {
//            resetPropertiesOfCannedMessage()
//        }
//
//        titleLabel.text = cannedObject.title ?? ""
//        if let desc =  cannedObject.message {
//        descriptionLabel.text = desc.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        } else {
//         descriptionLabel.text = ""
//        }
//        return self
//    }
//
//    func setTheme() {
//        let theme = HippoTheme.theme
//        titleLabel.textColor = theme.label.primary
//        descriptionLabel.textColor = theme.label.secondary
//
//        horizontalLine.backgroundColor = theme.sepratorColor
//    }
//}
