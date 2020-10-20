//
//  ActionSheetViewController.swift
//  Hippo
//
//  Created by Arohi Sharma on 14/10/20.
//

import Foundation
import UIKit

class ActionSheetViewController: UIViewController {

    @IBOutlet var optionViewHeightContraint: NSLayoutConstraint!
    @IBOutlet var bgView: UIView!
    @IBOutlet var nochBGView: UIView!
    @IBOutlet var nochView: UIView!
    @IBOutlet var optionContaintView: UIView!
    @IBOutlet var optionTableView: UITableView!
    
   
    enum ActionType: Int {
        case none = 0
        case emoji
    }
    
    var emojiSelected: ((_ reactionString: String) -> Void)!
    var optionSelection: ((_ action: ActionSheetAction)->Void)!
    var options = [ActionSheetAction]()
    var type: ActionType = .none
    var height: CGFloat = 0
    var tap: UITapGestureRecognizer!
    var swipe:UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        bgView.addGestureRecognizer(tap)
        swipe = UISwipeGestureRecognizer(target: self, action: #selector(tapOnView))
        swipe.direction = .down
        bgView.addGestureRecognizer(swipe)
        nochView.layer.cornerRadius = 2
        nochView.backgroundColor = .white
        bgView.isHidden = true
        optionContaintView.isHidden = true
        optionViewHeightContraint.constant = 0
    
    }
    

    class func get(with options: [ActionSheetAction], type: ActionType, emojiSelected: @escaping (_ reactionString: String) -> Void , optionSelected: @escaping(_ action: ActionSheetAction)->Void ) -> ActionSheetViewController {
        
        guard let vc = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle).instantiateViewController(withIdentifier: "ActionSheetViewController") as? ActionSheetViewController else{
            return ActionSheetViewController()
        }
        vc.emojiSelected = emojiSelected
        vc.optionSelection = optionSelected
        vc.type = type
        vc.options = options
        vc.heightCalculation()
        return vc
    }
    
    
    func heightCalculation() {
        height = 0
        if type == .emoji {
            height = 64
        }
        height += CGFloat(options.count * 50)
    }
    
    
    
    
    func showViewAnimation() {
         bgView.alpha = 0
         bgView.isHidden = false
         optionContaintView.isHidden = false
      
        self.optionViewHeightContraint.constant = self.view.frame.size.height - 60 > self.height ? self.height : self.view.frame.size.height - 60
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.bgView.alpha = 1
            self.view.layoutIfNeeded()
        }) { (mark) in
          self.round()
        }
    }
    
    
    
    func round() {
        let path = UIBezierPath(roundedRect: optionContaintView.bounds, byRoundingCorners: [.topRight,.topLeft ], cornerRadii: CGSize(width: 8, height: 8))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        optionContaintView.layer.mask = mask
        // Do any additional setup after loading the view.
    }
    
    @objc func tapOnView() {
        bgView.alpha = 0
        self.dismiss(animated: true, completion: nil)
    }

}


extension ActionSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionSheetTableViewCell" ) as! ActionSheetTableViewCell
        let action = options[indexPath.row]
        cell.setData(with: action)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = options[indexPath.row]
        self.dismiss(animated: false, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            action.handler?(action)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

struct ActionSheetAction {
    var icon: UIImage?
    var title: String
    var subTitle: String?
    var attTitle: NSAttributedString?
    var tag: Int?
    var handler: ((_ action:ActionSheetAction )->Void)?
    
    init(icon: UIImage? , title: String , subTitle: String? , attTitle: NSAttributedString?, tag: Int? , handler: ((ActionSheetAction) -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subTitle = subTitle
        self.attTitle = attTitle
        self.tag = tag
        self.handler = handler
        
    }
    
}



class ActionSheetTableViewCell: UITableViewCell {
    @IBOutlet var iconImgView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.regular(ofSize: 16.0)
        titleLabel.textColor = UIColor.black
    }
    
    func setData(with action: ActionSheetAction) {
        if #available(iOS 13.0, *) {
            iconImgView.image = action.icon?.withTintColor(UIColor.black)
        } else {
            iconImgView.tintColor = UIColor.black
            iconImgView.image = action.icon
        }
        titleLabel.text = action.title
    }
}
