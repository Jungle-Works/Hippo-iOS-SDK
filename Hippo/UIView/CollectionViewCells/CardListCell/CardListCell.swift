//
//  CardListCell.swift
//  HippoChat
//
//  Created by Vishal on 21/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol CardListCellDelegate: class {
    func labelContainerClicked(card: MessageCard)
    func readmoreClicked(card: MessageCard)
}

class CardListCell: UICollectionViewCell {

    static let ratingViewHeight: CGFloat = 20
    
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingViewContainer: UIView!
    @IBOutlet weak var imageView: HippoImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: HippoLabel!
    @IBOutlet weak var labelContainterView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var ratingContainerViewHeightConstraint: NSLayoutConstraint!
    
    var card: MessageCard?
    var ratingView: HCSStarRatingView?
    weak var delegate: CardListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }

    func setTheme() {
        let theme = HippoConfig.shared.theme
        labelContainterView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        titleLabel.textColor = .white
        descriptionLabel.textColor = .darkText
        bgView.hippoCornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        bgView.backgroundColor = .white
        bottomContainer.backgroundColor = .white
        ratingViewContainer.backgroundColor = .clear
        descriptionLabel.numberOfLines = 2
        ratingLabel.textColor = .white
        descriptionLabel.font = UIFont.bold(ofSize: 11)//UIFont.boldSystemFont(ofSize: 11)
        infoImageView.image = theme.infoIcon
        infoImageView.tintColor = theme.infoIconTintColor
        bgView.layer.borderColor = theme.themeColor.cgColor
        bgView.layer.borderWidth = 1
        ratingViewContainer.isUserInteractionEnabled = false
        
    }
    
    private func setDescriptionLabel() {
        let desc = (card?.description ?? "")
        descriptionLabel.text = desc
        let readmoreFont = descriptionLabel.font //If font changes calculation is to be changed
        let readmoreFontColor = UIColor.blue
        
        let isTrailingAdded = self.descriptionLabel.addTrailing(with: "...", moreText: HippoStrings.readMore, moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
        
        
        if isTrailingAdded {
            descriptionLabel.isUserInteractionEnabled = true
            addGesture()
        } else {
            descriptionLabel.isUserInteractionEnabled = false
            removeGesture()
        }
    }
    
    private func addGesture() {
        descriptionLabel.removeAllGesture()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelClicked))
        descriptionLabel.addGestureRecognizer(tapGesture)
    }
    
    private func addLAbelContainerViewGesture() {
        labelContainterView.removeAllGesture()
        let conatinerLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(labelContainerClicked))
        labelContainterView.isUserInteractionEnabled = true
        labelContainterView.addGestureRecognizer(conatinerLabelTapGesture)
    }
    
    @objc private func labelContainerClicked() {
        if let card = card {
            delegate?.labelContainerClicked(card: card)
        }
    }
    
    @objc private func labelClicked() {
        if let card = self.card {
            delegate?.readmoreClicked(card: card)
        }
//        let message = (card?.description ?? "")
//        showAlertWith(message: message, action: nil)
    }
    private func removeGesture() {
        descriptionLabel.removeAllGesture()
    }
    
    private func initalizeRatingView() {
        ratingView?.removeFromSuperview()
        ratingView = nil
        
        ratingContainerViewHeightConstraint.constant = CardListCell.ratingViewHeight
        ratingViewContainer.isHidden = false
        self.layoutIfNeeded()
        let containerBound = ratingViewContainer.bounds
        let width = (containerBound.size.width)
        let bounds = CGRect(x: containerBound.origin.x, y: containerBound.origin.y, width: width, height: containerBound.size.height)
        ratingView = HCSStarRatingView(frame: bounds)
        ratingView?.allowsHalfStars = true
        ratingView?.isUserInteractionEnabled = false
        ratingView?.tintColor = HippoConfig.shared.theme.starRatingColor
        ratingView?.backgroundColor = .clear
        if let parsedRatingView = ratingView {
            ratingViewContainer.addSubview(parsedRatingView)
        }
    }
    private func setRating() {
        guard let rating = card?.rating, rating > 0 else {
            hideRatingView()
            return
        }
        initalizeRatingView()
        ratingView?.maximumValue = 1
        ratingView?.value = 1
        ratingLabel.text = "\(rating)"
    }
    
    private func hideRatingView() {
        ratingView?.removeFromSuperview()
        ratingView = nil
        ratingContainerViewHeightConstraint.constant = 0
        ratingViewContainer.isHidden = true
    }
}
extension CardListCell {
    func set(card: MessageCard) {
        self.card = card
        titleLabel.text = card.title
        let placeholder: UIImage? = UIImage(named: "placeholderImg", in: FuguFlowManager.bundle, compatibleWith: nil)
        imageView.setImage(resource: card.image, placeholder: placeholder)
        addLAbelContainerViewGesture()
        setDescriptionLabel()
        setRating()
    }
}


extension UIView {
    func removeAllGesture() {
        let gestures = self.gestureRecognizers ?? []
        for each in gestures {
            self.removeGestureRecognizer(each)
        }
    }
}
