//
//  ImageTableViewCell.swift
//  AFNetworking
//
//  Created by socomo on 14/12/17.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var messageImageView: So_UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
//MARK: - HELPERS
extension ImageTableViewCell {
    func setupIndicatorView(_ show: Bool) {
        customImageView.image = UIImage(named: "app_loader_shape", in: FuguFlowManager.bundle, compatibleWith: nil)
        if show {
            startIndicatorAnimation()
            customImageView.isHidden = false
        } else {
            stopIndicatorAnimation()
            customImageView.isHidden = true
        }
    }
    
    func startIndicatorAnimation() {
        customImageView.startRotationAnimation()
    }
    
    func stopIndicatorAnimation() {
        customImageView.stopRotationAnimation()
    }
}
