//
//  OtplessLoader.swift
//  OtplessSDK
//
//  Created by Otpless on 07/02/23.
//

import UIKit


class OtplessLoader: UIView {
        
        private var closeButton = UIButton(type: .system)
        private var label = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupView()
        }

        private func setupView() {
            backgroundColor = UIColor.black.withAlphaComponent(0.7)
            label.frame = CGRect(x:  (UIScreen.main.bounds.width - 100)/2, y:  (UIScreen.main.bounds.height - 100)/2, width: 100, height: 100)
                           addSubview(label)
            label.text = "Verifying..."
            label.textColor = UIColor.white
            label.textAlignment = .center
            
            addSubview(closeButton)
            closeButton.setTitleColor(UIColor.white, for: .normal)
            closeButton.titleLabel?.textAlignment = .center
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            closeButton.setTitle("Cancel", for: .normal)
            closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        }

    @objc func closeButtonTapped(){
        self.removeFromSuperview()
    }
    
    public func show(){
        DispatchQueue.main.async { [self] in
            self.frame = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            let window = UIApplication.shared.windows.last!
            window.addSubview(self)
        }
        
    }
    
    public func hide(){
        DispatchQueue.main.async { [self] in
            self.removeFromSuperview()
        }
    }
}

