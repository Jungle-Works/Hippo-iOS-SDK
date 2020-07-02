
import UIKit

class SuggestionCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let theme = HippoConfig.shared.theme
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 12.0, *) {
            let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
            let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
            let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
            let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        }
    }

    func prepareCellWith(title: String) {
        self.titleLabel.text = title
        layoutIfNeeded()
        containerView.backgroundColor = theme.themeColor
        containerView.layer.borderColor = theme.themeTextcolor.cgColor
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = containerView.frame.height/2
        titleLabel.textColor = theme.themeTextcolor
    }
    
    func prepareCellUI() {
        layoutIfNeeded()
        DispatchQueue.main.async {
            self.containerView.backgroundColor = self.theme.themeColor
            self.containerView.layer.borderColor = self.theme.themeTextcolor.cgColor
            self.containerView.layer.borderWidth = 1.0
            self.containerView.layer.cornerRadius = self.containerView.frame.height/2
            self.titleLabel.textColor = self.theme.themeTextcolor
        }
    }
}
