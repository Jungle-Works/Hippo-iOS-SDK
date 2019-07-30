//
//  UIViewController+Extension.swift
//  BRYXBanner
//
//  Created by cl-macmini-117 on 01/11/17.
//

import UIKit



extension UIView {
    @IBInspectable var _cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        } get {
            return self.layer.cornerRadius
        }
    }
    
    
    class var tableAutoDimensionHeight: CGFloat {
        #if swift(>=4.2)
        return UITableView.automaticDimension
        #else
        return UITableViewAutomaticDimension
        #endif
    }
    class var safeAreaInsetsForAllOS: UIEdgeInsets {
        var insets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets()
        } else {
            insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }
        return insets
    }
   static var safeAreaInsetOfKeyWindow: UIEdgeInsets {
      return safeAreaInsetsForAllOS
   }
    
   // MARK: - Rotation Animation
   private var rotationAnimationKey: String {
      return "FuguRotationAnimation"
   }
   
   func startRotationAnimation() {
      isHidden = false
      
      guard !isRotationAnimationAlreadyHappning() else {
         return
      }
      
      UIView.animate(withDuration: 1) {
         let rotationAnimation = self.getRotationAnimation()
         self.layer.add(rotationAnimation, forKey: self.rotationAnimationKey)
      }

   }
   
   
   func stopRotationAnimation() {
      if isRotationAnimationAlreadyHappning() {
         layer.removeAnimation(forKey: rotationAnimationKey)
      }
      isHidden = true
   }
   
   private func isRotationAnimationAlreadyHappning() -> Bool {
      return layer.animation(forKey: rotationAnimationKey) != nil
   }
   
   private func getRotationAnimation() -> CABasicAnimation {
      let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
      rotationAnimation.fromValue = 0.0
      rotationAnimation.toValue = Float(.pi * 2.0)
      rotationAnimation.duration = 1
      rotationAnimation.repeatCount = Float.infinity
      return rotationAnimation
   }
}

extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return  layer.borderColor == nil ? nil : UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension TagListView {
    func setTagListViewProperty() {
        alignment = HippoConfig.shared.appUserType == .agent ? .left : .right
        borderColo = HippoConfig.shared.theme.headerBackgroundColor
        paddingY = 10
        paddingX = 20
        borderWidth = 1
        textColor =  HippoConfig.shared.theme.headerBackgroundColor
        selectedTextColor =  HippoConfig.shared.theme.headerBackgroundColor
        textFont = HippoConfig.shared.theme.incomingMsgFont
    }
}
extension UINavigationController {
    func setTheme() {
        navigationBar.tintColor = HippoConfig.shared.theme.headerTextColor
        navigationBar.barTintColor = HippoConfig.shared.theme.headerBackgroundColor
        navigationBar.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        navigationBar.isTranslucent = false
        
        #if swift(>=4.0)
        var attributes: [NSAttributedString.Key : Any]  = [NSAttributedString.Key.foregroundColor: HippoConfig.shared.theme.headerTextColor]
        attributes[NSAttributedString.Key.font] = HippoConfig.shared.theme.headerTextFont
        #else
        var attributes: [String : Any]  = [NSForegroundColorAttributeName: HippoConfig.shared.theme.headerTextColor]
        attributes[NSFontAttributeName] = HippoConfig.shared.theme.headerTextFont
        
        #endif
        navigationBar.titleTextAttributes = attributes
    }
}
extension UIViewController {
    func showAlert(_ inController: UIViewController? = getLastVisibleController(), buttonTitle: String = "OK", title: String?, message: String, preferredStyle: UIAlertController.Style = .alert, actionComplete: ((_ action: UIAlertAction) -> Void)?) {
        let alertMessageController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: actionComplete)
        
        alertMessageController.addAction(okAction)
        
        inController?.present(alertMessageController, animated: true, completion: nil)
    }

    
    func showOptionAlert(title: String?, message: String, preferredStyle: UIAlertController.Style = .alert, successButtonName: String, successComplete: ((_ action: UIAlertAction) -> Void)?, failureButtonName: String, failureComplete: ((_ action: UIAlertAction) -> Void)?) {
        let alertMessageController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        let noAlertAction = UIAlertAction(title: failureButtonName, style: .default, handler: failureComplete)
        alertMessageController.addAction(noAlertAction)
        
        let okAlertAction = UIAlertAction(title: successButtonName, style: .default, handler: successComplete)
        alertMessageController.addAction(okAlertAction)
        
        self.present(alertMessageController, animated: true, completion: nil)
    }
    func showAlert(title: String?, message: String, preferredStyle: UIAlertController.Style = .alert, buttonTitle: String, completion: ((_ action: UIAlertAction) -> Void)?) {
        let alertMessageController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        let noAlertAction = UIAlertAction(title: buttonTitle, style: .default, handler: completion)
        alertMessageController.addAction(noAlertAction)
        
        self.present(alertMessageController, animated: true, completion: nil)
    }
    func removeNotificationsFromNotificationCenter(channelId: Int) {
        HippoNotification.removeAllnotificationFor(channelId: channelId)
    }
    func removeKeyboardNotificationObserver() {
        #if swift(>=4.2)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        #else
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        #endif
    }
    
    func removeAppDidEnterForegroundObserver() {
        #if swift(>=4.2)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        #else
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        #endif
        
    }
    
    func removeNotificationObserverToKnowWhenAppIsKilledOrMovedToBackground() {
        #if swift(>=4.2)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        #else
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        #endif
    }
}

extension UIButton {
    func startLoading() {
        for view in self.subviews where view is UIActivityIndicatorView {
            guard let activityIndicator = view as? UIActivityIndicatorView else {
                return
            }
            self.titleLabel?.alpha = 0.0
            activityIndicator.startAnimating()
            return
        }
        
        // Create Activity Indicator
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        let buttonHeight = self.bounds.size.height
        let buttonWidth = self.bounds.size.width
        activityIndicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        self.titleLabel?.alpha = 0.0
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        for view in self.subviews where view is UIActivityIndicatorView {
            view.removeFromSuperview()
            self.titleLabel?.alpha = 1.0
        }
    }
}
