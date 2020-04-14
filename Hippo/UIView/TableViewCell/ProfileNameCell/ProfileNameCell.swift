//
//  ProfileNameCell.swift
//  HippoChat
//
//  Created by Vishal on 26/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class ProfileNameCell: UITableViewCell {

    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var ratingSubView: HCSStarRatingView?
    var profile: ProfileDetail?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    internal func setTheme() {
        let theme = HippoConfig.shared.theme
        ratingLabel.font = theme.ratingLabelFont
        ratingLabel.textColor = theme.ratingLabelTextFontColor
        
        nameLabel.font = theme.profileNameFont
        nameLabel.textColor = theme.profileNameTextColor
        
        ratingContainerView.clipsToBounds = true
    }
    
    private func initalizeRatingView() {
        ratingSubView?.removeFromSuperview()
        ratingSubView = nil
        
        ratingContainerView.isHidden = false
        self.layoutIfNeeded()
        let containerBound = ratingView.bounds
        let width = (containerBound.size.width)
        let bounds = CGRect(x: containerBound.origin.x, y: containerBound.origin.y, width: width, height: containerBound.size.height)
        ratingSubView = HCSStarRatingView(frame: bounds)
        ratingSubView?.allowsHalfStars = true
        ratingSubView?.isUserInteractionEnabled = false
        ratingSubView?.tintColor = HippoConfig.shared.theme.starRatingColor
        ratingSubView?.backgroundColor = .clear
        if let parsedRatingView = ratingSubView {
            ratingView.addSubview(parsedRatingView)
        }
    }
    private func setRating() {
        guard let rating = profile?.rating, rating > 0 else {
            hideRatingView()
            return
        }
        initalizeRatingView()
        ratingSubView?.maximumValue = 1
        ratingSubView?.value = 1
        ratingLabel.text = "\(rating)"
    }
    private func hideRatingView() {
        ratingSubView?.removeFromSuperview()
        ratingSubView = nil
        ratingContainerView.isHidden = true
    }
}

extension ProfileNameCell {
    func set(profile: ProfileDetail) {
        self.profile = profile
        
        nameLabel.text = profile.fullName ?? ""
        setRating()
    }
}
