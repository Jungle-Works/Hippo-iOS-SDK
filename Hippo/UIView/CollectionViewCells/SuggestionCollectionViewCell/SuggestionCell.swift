
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

    private let colorConfig = HippoConfig.shared.colorConfig

    func prepareCellWith(title: String) {
        self.titleLabel.text = title
        layoutIfNeeded()
        applyChipStyle()
    }

    func prepareCellUI() {
        layoutIfNeeded()
        DispatchQueue.main.async {
            self.applyChipStyle()
        }
    }

    // White pill on the chat-background strip: surface fill, hairline border,
    // accent-coloured label.
    private func applyChipStyle() {
        containerView.backgroundColor = colorConfig.hippoSurface
        containerView.layer.borderColor = colorConfig.hippoBorder.cgColor
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = containerView.frame.height / 2
        titleLabel.textColor = colorConfig.hippoAccent
    }
}
