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
                                                                       width: FUGU_SCREEN_WIDTH,
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

    /// Set once a real profile photo has loaded, so a later re-layout doesn't matter
    /// and a failed load keeps the initials avatar.
    private var hasRemoteProfileImage = false
    
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
//         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleViewClicked))
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
        hasRemoteProfileImage = false
        showProfileImage()
        // Fixed-size render — independent of the view's bounds, which are often still
        // .zero when setData() runs from viewWillAppear (that's why the old
        // bounds-based setTextInImage produced nothing for the visitor header).
        image_profile.contentMode = .scaleAspectFit
        image_profile.image = NavigationBarChat.initialsImage(for: name)

        // `URL(string: "")` is NOT nil, so the old guard fell through for a visitor
        // with no photo and handed Kingfisher an empty URL — which wiped the image.
        let trimmed = imageUrl?.trimWhiteSpacesAndNewLine() ?? ""
        guard !trimmed.isEmpty, let url = URL(string: trimmed), url.host != nil else {
            return
        }

        image_profile.contentMode = .scaleAspectFill
        image_profile.kf.setImage(with: url, placeholder: image_profile.image,  completionHandler: { [weak self] (image, error, _, _) in
            if error == nil, image != nil {
                self?.hasRemoteProfileImage = true
            } else if let parsedError = error {
                print(parsedError.localizedDescription)
            }
        })
    }

    /// A 35pt circular avatar with the first letter of `name` — a bounds-free
    /// replacement for `UIImageView.setTextInImage`, which needs the view laid out.
    static func initialsImage(for name: String?) -> UIImage {
        let side: CGFloat = 35
        let trimmed = name?.trimWhiteSpacesAndNewLine() ?? ""
        let letter = trimmed.isEmpty ? "?" : String(trimmed.first!).uppercased()
        // Same per-initial pastel the conversation list uses (FuguHelpers.material /
        // getColor), so the header avatar matches the list avatar.
        let fill = UIColor.hexStringToUIColor(hex: material[getColor(char: letter)])
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: side, height: side)
            fill.setFill()
            ctx.cgContext.fillEllipse(in: rect)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.regular(ofSize: 16),
                .foregroundColor: UIColor.white
            ]
            let ts = (letter as NSString).size(withAttributes: attrs)
            (letter as NSString).draw(in: CGRect(x: (side - ts.width) / 2,
                                                 y: (side - ts.height) / 2,
                                                 width: ts.width,
                                                 height: ts.height),
                                      withAttributes: attrs)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if HippoConfig.shared.appUserType == .customer, image_profile.bounds.height > 1 {
            image_profile.layer.cornerRadius = image_profile.bounds.height / 2
            image_profile.layer.masksToBounds = true
        }
    }
    
    
    func hideProfileImage() {
         image_profile.isHidden = true
         layoutIfNeeded()
     }
     
     func showProfileImage() {
         image_profile.isHidden = false
         layoutIfNeeded()
         if HippoConfig.shared.appUserType == .customer {
             // Full circle with a thin border, matching the revamped customer thread's avatar
             // treatment elsewhere - layoutIfNeeded() above first so bounds are already
             // resolved, since image_profile has no fixed size constraint (only a 1:1 aspect
             // ratio) to compute a radius from ahead of layout.
             image_profile.layer.cornerRadius = image_profile.bounds.height / 2
             image_profile.layer.borderWidth = 1
             image_profile.layer.borderColor = HippoConfig.shared.colorConfig.hippoBorder.cgColor
         } else {
             image_profile.layer.cornerRadius = 8
         }
         image_profile.layer.masksToBounds = true
         layoutIfNeeded()
     }
    
    func setBackButton(hide: Bool) {
        image_back.isHidden = hide
        leftButton.isEnabled = !hide
    }
    
    func setNameAsTitle(_ name: String?) {
        if let parsedName = name {
            let isCircular = HippoConfig.shared.appUserType == .customer
            self.image_profile.setTextInImage(string: parsedName, color: UIColor.lightGray, circular: isCircular)
        } else {
          self.image_profile.image = HippoConfig.shared.theme.placeHolderImage
        }
    }
}

