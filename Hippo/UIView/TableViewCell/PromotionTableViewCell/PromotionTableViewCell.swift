//
//  PromotionTableViewCell.swift
//  HippoChat
//
//  Created by Clicklabs on 12/24/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

//protocol PromotionTableViewCellDelegate: AnyObject {
//    func readmoreClicked(data: PromotionCellDataModel)
//}

class PromotionTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var fullDescriptionLabel: UITextView!
    //@IBOutlet weak var descriptionLabel: HippoLabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var promotionTitle: UILabel!
    @IBOutlet weak var promotionImage: UIImageView!{
        didSet{
            promotionImage.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var showReadMoreLessButton: UIButton!
    @IBOutlet weak var showReadMoreLessButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraint_timeLabelBottom : NSLayoutConstraint!
    
    var data: PromotionCellDataModel?
    var previewImage : (()->())?
//    weak var delegate: PromotionTableViewCellDelegate?
    private var newBadgeView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpUI()
        self.setUpNewBadge()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(){
        bgView.layer.borderWidth = 0
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = UIColor.white

        promotionTitle.font = HippoConfig.shared.theme.promotionTitle
        promotionTitle.textColor = .black

        let zeroPadding = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
        descriptionLabel.textContainerInset = zeroPadding
        descriptionLabel.textContainer.lineFragmentPadding = 0
        descriptionLabel.textColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1.0)
        descriptionLabel.font = HippoConfig.shared.theme.descriptionFont

        fullDescriptionLabel.textContainerInset = zeroPadding
        fullDescriptionLabel.textContainer.lineFragmentPadding = 0
        fullDescriptionLabel.textColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1.0)
        fullDescriptionLabel.font = HippoConfig.shared.theme.descriptionFont

        dateTimeLabel.font = HippoConfig.shared.theme.dateTimeFontSize
        dateTimeLabel.textColor = UIColor(red: 113/255, green: 113/255, blue: 113/255, alpha: 1.0)
    }

    private func setUpNewBadge() {
        guard let stack = promotionTitle.superview as? UIStackView else { return }

        let pill = UIView()
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = UIColor(red: 231/255, green: 239/255, blue: 253/255, alpha: 1.0)
        pill.layer.cornerRadius = 10
        pill.layer.masksToBounds = true

        let dotSize: CGFloat = 6
        let dotView = UIView()
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = UIColor(red: 22/255, green: 68/255, blue: 153/255, alpha: 1.0)
        dotView.layer.cornerRadius = dotSize / 2
        dotView.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            dotView.widthAnchor.constraint(equalToConstant: dotSize),
            dotView.heightAnchor.constraint(equalToConstant: dotSize)
        ])

        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        newLabel.text = "New"
        newLabel.font = UIFont.boldSystemFont(ofSize: 12)
        newLabel.textColor = UIColor(red: 22/255, green: 68/255, blue: 153/255, alpha: 1.0)

        let innerStack = UIStackView(arrangedSubviews: [dotView, newLabel])
        innerStack.axis = .horizontal
        innerStack.spacing = 4
        innerStack.alignment = .center
        innerStack.translatesAutoresizingMaskIntoConstraints = false

        pill.addSubview(innerStack)
        NSLayoutConstraint.activate([
            innerStack.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 8),
            innerStack.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -8),
            innerStack.topAnchor.constraint(equalTo: pill.topAnchor, constant: 3),
            innerStack.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -3)
        ])

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        container.addSubview(pill)
        NSLayoutConstraint.activate([
            pill.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            pill.topAnchor.constraint(equalTo: container.topAnchor),
            pill.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            pill.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])

        stack.insertArrangedSubview(container, at: 0)
        newBadgeView = container
    }

    func set(data: PromotionCellDataModel){

        self.data = data
        newBadgeView.isHidden = data.seenStatus != 0

        if data.imageUrlString.isEmpty{
            self.promotionImage?.isHidden = true
            self.imageHeightConstraint.constant = 0
            self.constraint_timeLabelBottom.constant = 0
        }else{
            self.imageHeightConstraint.constant = self.promotionImage.frame.size.width / 2.5
            self.promotionImage?.isHidden = false
            let url = URL(string: data.imageUrlString)
            self.promotionImage.kf.setImage(with: url, placeholder: HippoConfig.shared.theme.placeHolderImage, options: nil, progressBlock: nil)
            self.constraint_timeLabelBottom.constant = 4
        }
//        self.promotionTitle.text = data.title//"This is a new tittle"
       
       // self.promotionTitle.backgroundColor = UIColor.yellow
//        self.descriptionLabel.text = data.description//"This is description of promotion in a new format"
   //        setDescriptionLabel()
        
        // print("text >>> \(self.descriptionLabel.text) height >> \(data.cellHeight)")
        
       // self.descriptionLabel.backgroundColor = UIColor.blue
        
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = iso8601Formatter.date(from: data.createdAt)
        dateTimeLabel.text = date?.toString ?? ""
    

        self.layoutIfNeeded()
    }
    
    @IBAction func action_PreviewImage(){
        self.previewImage?()
    }
    
    
//    private func setDescriptionLabel() {
//        let desc = (data?.description ?? "")
//        descriptionLabel.text = desc
//        let readmoreFont = descriptionLabel.font //If font changes calculation is to be changed
//        let readmoreFontColor = UIColor.blue
//
//        let isTrailingAdded = self.descriptionLabel.addTrailing(with: "...", moreText: "Read More", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
//
//
//        if isTrailingAdded {
//            descriptionLabel.isUserInteractionEnabled = true
//            addGesture()
//        } else {
//            descriptionLabel.isUserInteractionEnabled = false
//            removeGesture()
//        }
//    }
//    private func addGesture() {
//        descriptionLabel.removeAllGesture()
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelClicked))
//        descriptionLabel.addGestureRecognizer(tapGesture)
//    }
//    private func removeGesture() {
//        descriptionLabel.removeAllGesture()
//    }
//    @objc private func labelClicked() {
//        if let data = self.data {
//            delegate?.readmoreClicked(data: data)
//        }
////        let message = (card?.description ?? "")
////        showAlertWith(message: message, action: nil)
//    }
}
