//
//  NavigationBar.swift
//  Hippo
//
//  Created by Arohi Sharma on 22/05/20.
//

import Foundation
import UIKit

final class NavigationBarChat: UIView {
    
    private static let NIB_NAME = "NavigationBarChat"
    
    @IBOutlet var view: UIView!{
        didSet{
            view.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            view.layer.shadowRadius = 3.0
            view.layer.shadowOpacity = 0.5
            view.layer.masksToBounds = false
            view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                                       y: bounds.maxY - layer.shadowRadius,
                                                                       width: UIScreen.main.bounds.width,
                                                                       height: layer.shadowRadius)).cgPath
        }
    }
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var call_button : UIButton!{
        didSet{
            call_button.setImage(HippoConfig.shared.theme.audioCallIcon, for: .normal)
            call_button.tintColor = HippoConfig.shared.theme.headerTextColor
        }
    }
    @IBOutlet weak var video_button : UIButton!{
        didSet{
           video_button.setImage(HippoConfig.shared.theme.videoCallIcon, for: .normal)
           video_button.tintColor = HippoConfig.shared.theme.headerTextColor
        }
    }
    @IBOutlet private weak var image_profile : UIImageView!
    
    @IBOutlet private weak var image_back : UIImageView!{
        didSet{
            image_back.tintColor = HippoConfig.shared.theme.titleTextColor
            image_back.image = HippoConfig.shared.theme.leftBarButtonImage
        }
    }
    @IBOutlet weak var info_button : UIButton!
    
   // @IBOutlet weak var descLabel : UILabel!
    
    
    var isLeftButtonHidden: Bool {
        set {
            leftButton.isHidden = newValue
        }
        get {
            return leftButton.isHidden
        }
    }
    
    weak var delegate: NavigationTitleViewDelegate?
    
    
    override func awakeFromNib() {
        initWithNib()
        setupDefaultUI()
        addGesture()
    }
    
    private func initWithNib() {
        FuguFlowManager.bundle?.loadNibNamed(NavigationBarChat.NIB_NAME, owner: self, options: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
         delegate?.backButtonClicked()
     }
     
    
    func setupDefaultUI() {
        titleLabel.font = HippoConfig.shared.theme.headerTextFont
        titleLabel.textColor = HippoConfig.shared.theme.headerTextColor
    
        hideProfileImage()
        
       // hideDescription()
       // descLabel.text = "tap to view info"
        titleLabel.text = ""
    }
    
    
    
    func setTitle(title: String) {
        titleLabel.text = "  " + title.trimWhiteSpacesAndNewLine()
    }
    
    func addGesture() {
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleViewClicked))
        // labelContainer.addGestureRecognizer(tapGesture)
         image_profile.isUserInteractionEnabled = true
         let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageClicked))
         image_profile.addGestureRecognizer(imageTapGesture)
     }
    
        @objc func titleViewClicked() {
            delegate?.titleClicked?()
        }
        @objc func imageClicked() {
    //        if backButton.isEnabled {
                delegate?.imageIconClicked?()
    //        }
        }

    func setData(imageUrl: String?, name: String?) {
        showProfileImage()
        setNameAsTitle(name)
        
        guard let url = URL(string: imageUrl ?? "") else {
            return
        }
        
        image_profile.contentMode = .scaleAspectFill
        image_profile.kf.setImage(with: url, placeholder: nil,  completionHandler: {(_, error, _, _) in
            guard let parsedError = error else {
                return
            }
            print(parsedError.localizedDescription)
        })
    }
    
    
    func hideProfileImage() {
         image_profile.isHidden = true
         layoutIfNeeded()
     }
     
     func showProfileImage() {
         image_profile.isHidden = false
         image_profile.layer.cornerRadius = 8//image_profile.frame.size.height/2
         image_profile.layer.masksToBounds = true
         layoutIfNeeded()
     }
    
    func setBackButton(hide: Bool) {
        image_back.isHidden = hide
        leftButton.isEnabled = !hide
    }
    
    func setNameAsTitle(_ name: String?) {
        if let parsedName = name {
            self.image_profile.setTextInImage(string: parsedName, color: UIColor.lightGray, circular: false)
        } else {
          self.image_profile.image = HippoConfig.shared.theme.placeHolderImage
        }
    }
}

