//
//  UIViewController+Extension.swift
//  BRYXBanner
//
//  Created by cl-macmini-117 on 01/11/17.
//

import UIKit

extension UIView {
   var safeAreaInsetsForAllOS: UIEdgeInsets {
      var insets: UIEdgeInsets
      if #available(iOS 11.0, *) {
         insets = safeAreaInsets
      } else {
         insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
      }
      return insets
   }
   
   static var safeAreaInsetOfKeyWindow: UIEdgeInsets {
      return UIApplication.shared.keyWindow?.safeAreaInsetsForAllOS ?? UIEdgeInsets()
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
    
    func addConstraintsWithFormat(format:String, views: UIView...){
        
        var viewsDictionary = [String:UIView]()
        
        for(index,view) in views.enumerated(){
            let key = "v\(index)"
            // Imp. so that you can add constraints manually
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
}

extension UINavigationController {
    func setTheme() {
        navigationBar.tintColor = HippoConfig.shared.theme.headerTextColor
        navigationBar.barTintColor = HippoConfig.shared.theme.headerBackgroundColor
        navigationBar.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        navigationBar.isTranslucent = false
        
        var attributes: [NSAttributedStringKey : Any]  = [NSAttributedStringKey.foregroundColor: HippoConfig.shared.theme.headerTextColor]
        attributes[NSAttributedStringKey.font] = HippoConfig.shared.theme.headerTextFont
        
        
        navigationBar.titleTextAttributes = attributes
    }
}
extension UIApplication {
   func clearNotificationCenter() {
      applicationIconBadgeNumber = 1
      applicationIconBadgeNumber = 0
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
