import UIKit
class CannedMessageTableViewCell: CoreTabelViewCell {

    
    
    
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var descriptionLabel: So_CustomLabel!
    @IBOutlet weak var titleLabel: So_CustomLabel!
    @IBOutlet weak var horizontalLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension CannedMessageTableViewCell {
    func resetPropertiesOfCannedMessage() {
        clipsToBounds = true
        setTheme()
//        backgroundColor = .clear
//        accessoryType = .disclosureIndicator
       // horizontalLine.isHidden = true
    }

    func configureCannedMessageCell(resetProperties: Bool, cannedObject: CannedReply) -> CannedMessageTableViewCell {
        if resetProperties == true {
            resetPropertiesOfCannedMessage()
        }
        
        titleLabel.text = cannedObject.title ?? ""
        if let desc =  cannedObject.message {
        descriptionLabel.text = desc.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
         descriptionLabel.text = ""
        }
        return self
    }
    
    func setTheme() {
        
        descriptionLabel.font = UIFont.regular(ofSize: 17.0)
        descriptionLabel.textColor = HippoConfig.shared.theme.lightThemeTextColor//theme.label.primary
        titleLabel.font = UIFont.regular(ofSize: 17.0)
        titleLabel.textColor = HippoConfig.shared.theme.lightThemeTextColor
        backgroundColor = .clear
       // horizontalLine.backgroundColor = UIColor.gray//theme.sepratorColor
        horizontalLine.backgroundColor = UIColor.black
        
    }
}
