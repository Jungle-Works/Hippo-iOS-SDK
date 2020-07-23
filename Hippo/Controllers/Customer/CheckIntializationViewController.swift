//
//  CheckIntializationViewController.swift
//  SDKDemo1
//
//  Created by cl-macmini-117 on 07/12/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

/*class CheckIntializationViewController: UIViewController {

   // MARK: - Properties
   var completion: ((_ presentingViewController: UIViewController) -> Void)?
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var loaderImage: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tryaginButton: UIButton!
   @IBOutlet weak var backButton: UIButton!
   
   // MARK: - View Life Cycle
   override func viewDidLoad() {
      super.viewDidLoad()
      
      configureUI()
      
      if HippoUserDetail.fuguUserID != nil {
         intializationComplete()
      } else {
         tryAgainButtonPressed(tryaginButton)
      }
   }
   
   func configureUI() {
      let theme = HippoConfig.shared.theme
      
      view.backgroundColor = theme.backgroundColor
      headerView.backgroundColor = theme.headerBackgroundColor
      
      backButton.setImage(theme.leftBarButtonImage, for: .normal)
      backButton.setTitle(theme.leftBarButtonText, for: .normal)
      backButton.setTitleColor(theme.leftBarButtonTextColor, for: .normal)
      backButton.tintColor = theme.leftBarButtonTextColor
      backButton.titleLabel?.font = theme.leftBarButtonFont
      
      tryaginButton.setTitleColor(theme.headerBackgroundColor, for: .normal)
      
      errorLabel.text = ""
      errorLabel.textColor = theme.typingTextColor
      errorLabel.font = theme.headerTextFont
   }
    
    // MARK: - IBAction
    @IBAction func tryAgainButtonPressed(_ sender: Any) {
        updateUIWhen(isRetrying: true)
        retryPutUser()
    }
    
   @IBAction func backButtonPressed(_ sender: UIButton) {
      dismiss(animated: true, completion: nil)
   }
   
   // MARK: - Methods
    func retryPutUser() {
        HippoUserDetail.getUserDetailsAndConversation { [weak self] (success, error) in
            guard success else {
                self?.errorLabel.text = error?.localizedDescription ??  HippoStrings.somethingWentWrong
                self?.updateUIWhen(isRetrying: false)
                return
            }
            
            self?.intializationComplete()
        }
    }
    
   func updateUIWhen(isRetrying: Bool) {
      tryaginButton.isHidden = isRetrying
      errorLabel.isHidden = isRetrying
      loaderImage.isHidden = !isRetrying
      
      if isRetrying {
         loaderImage.startRotationAnimation()
      } else {
         loaderImage.stopRotationAnimation()
      }
   }
   
   func intializationComplete() {
      dismiss(animated: false, completion: nil)
//      completion?(self.presentingViewController ?? getLastVisibleController())
   }
    
    // MARK: - Navigation
    class func get(intializationComplete: @escaping (_ presentingViewController: UIViewController)-> Void) -> CheckIntializationViewController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "CheckIntializationViewController") as! CheckIntializationViewController
        vc.completion = intializationComplete
        return vc
    }
    
}
*/
