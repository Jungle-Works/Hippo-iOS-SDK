//
//  BottomPopupController.swift
//  Hippo
//
//  Created by Arohi Sharma on 16/06/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class BottomPopupController: UIViewController {
    
    //MARK:- Variables
    
    var paymentCancelled : (()->())?
    var popupdismissed : (()->())?
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var view_Background : UIView!
    @IBOutlet weak var view_Popup : UIView!{
        didSet{
            view_Popup.layer.cornerRadius = 10
            view_Popup.clipsToBounds = true
            if #available(iOS 11.0, *) {
                view_Popup.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
            } else {
                // Fallback on earlier versions
            }
        }
    }
    @IBOutlet weak var label_CancelPayemnt : UILabel!{
        didSet{
            label_CancelPayemnt.text = HippoStrings.cancelPaymentTitle
            label_CancelPayemnt.font = UIFont.bold(ofSize: 24.0)
            label_CancelPayemnt.textColor = .black
        }
    }
    @IBOutlet weak var label_CancelMessage : UILabel!{
        didSet{
            label_CancelMessage.text = HippoStrings.cancelPayment
            label_CancelMessage.font = UIFont.regular(ofSize: 18.0)
            label_CancelMessage.textColor = .black
        }
    }
    @IBOutlet weak var button_No : UIButton!{
        didSet{
            button_No.setTitle(HippoStrings.no, for: .normal)
            button_No.titleLabel?.font = UIFont.regular(ofSize: 18.0)
            button_No.setTitleColor(UIColor(red: 108/255, green: 108/255, blue: 108/255, alpha: 1.0), for: .normal)
            button_No.layer.borderWidth = 1
            button_No.layer.borderColor = UIColor(red: 108/255, green: 108/255, blue: 108/255, alpha: 1.0).cgColor
            button_No.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var button_Yes : UIButton!{
        didSet{
            button_Yes.setTitle(HippoStrings.yesCancel, for: .normal)
            button_Yes.titleLabel?.font = UIFont.regular(ofSize: 18.0)
            button_Yes.setTitleColor(.white, for: .normal)
            button_Yes.backgroundColor = HippoConfig.shared.theme.themeColor
            button_Yes.layer.cornerRadius = 6
        }
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

 
    

}
extension BottomPopupController{
    
    //MARK:- IBAction
    
    @IBAction func dismissView(){
        self.dismiss(animated: true, completion: nil)
        self.popupdismissed?()
    }
    
    @IBAction func Action_No(){
      self.dismiss(animated: true, completion: nil)
      self.popupdismissed?()
    }
    
    @IBAction func Action_Yes(){
        self.dismiss(animated: true, completion: nil)
        self.paymentCancelled?()
    }
}
