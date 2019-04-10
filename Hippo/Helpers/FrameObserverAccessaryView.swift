//
//  FrameObserverAccessaryView.swift
//  Fugu
//
//  Created by Gagandeep Arora on 04/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

class KeyBoard {
    
    static var height: CGFloat = 0
    static var width: CGFloat = 0
    static var isKeyBoardPresent: Bool {
        return height > 0
    }
    
    
    
    var heightChanged: ((CGFloat) -> Void)?
    
    init(heightChanged:  ((CGFloat) -> Void)?) {
        self.heightChanged = heightChanged
        registerKeyboardObservers()
    }
    
    private func registerKeyboardObservers() {
        #if swift(>=4.2)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidChangeHeight(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        #else
        NotificationCenter.default.addObserver(self, selector: #selector(KeyBoard.keyBoardWillShow(_:)), name: HippoVariable.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyBoard.keyBoardWillHide(_:)), name: HippoVariable.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidChangeHeight(_:)), name: HippoVariable.keyboardDidChangeFrameNotification, object: nil)
        #endif
    }
    
    @objc private func keyBoardWillShow(_ notification: Notification) {
        setHeightWidthFrom(notification: notification)
    }
    
    @objc private func keyBoardWillHide(_ notification: Notification) {
        KeyBoard.height = 0
        KeyBoard.width = 0
        heightChanged?(0)
    }
    
    @objc private func keyBoardDidChangeHeight(_ notification: Notification) {
        #if swift(>=4.2)
        let key = UIResponder.keyboardFrameEndUserInfoKey
        #else
        let key = UIKeyboardFrameEndUserInfoKey
        #endif
        guard let keyboardFrame = notification.userInfo?[key] as? CGRect, KeyBoard.height != 0 else {
            return
        }
        KeyBoard.height = keyboardFrame.height
        KeyBoard.width = keyboardFrame.width
        heightChanged?(KeyBoard.height)
    }
    
    private func setHeightWidthFrom(notification: Notification) {
        #if swift(>=4.2)
        let key = UIResponder.keyboardFrameEndUserInfoKey
        #else
        let key = UIKeyboardFrameEndUserInfoKey
        #endif
        let keyboardFrame = notification.userInfo?[key] as? CGRect
        KeyBoard.height = keyboardFrame?.height ?? 0
        KeyBoard.width = keyboardFrame?.width ?? 0
        heightChanged?(KeyBoard.height)
    }
    
    
}

class FrameObserverAccessaryView: UIView {
    var isObserverAdded = false
    var isKeyboardVisible: Bool {
        get {
            return keyboardFrame.minY < UIScreen.main.bounds.height
        }
    }
    
    typealias keyboardFrameChangedBlock = ((_ keyboardVisible: Bool, _ keyboardFrame: CGRect) -> Void)
    
    var keyboardChange: keyboardFrameChangedBlock?
    
    var _keyboardFrame = CGRect.zero
    var keyboardFrame: CGRect {
        set {
            let inputAccessoryViewHeight = self.bounds.height
            var frame = newValue
            frame.origin.y = frame.origin.y + inputAccessoryViewHeight
            frame.size.height = frame.size.height - inputAccessoryViewHeight
            
            _keyboardFrame = frame
            
            if keyboardChange != nil {
                keyboardChange?(isKeyboardVisible, frame)
            }
        }
        get {
            return _keyboardFrame
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeKeyboardFrame(change: @escaping keyboardFrameChangedBlock) {
        keyboardChange = change
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if isObserverAdded {
            self.superview?.removeObserver(self, forKeyPath: "frame")
            self.superview?.removeObserver(self, forKeyPath: "center")
        }
        
        newSuperview?.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        newSuperview?.addObserver(self, forKeyPath: "center", options: .new, context: nil)
        isObserverAdded = true
        
        super.willMove(toSuperview: newSuperview)
    }
    
    override func layoutSubviews() {
        guard let frame = self.superview?.frame else { return }
        
        keyboardFrame = frame
    }
    
    //MARK: - Observation
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard
            let superViewOfInputAccessory = self.superview,
            let givenObject = object as? UIView,
            givenObject == superViewOfInputAccessory,
            let givenKeyPath = keyPath,
            (givenKeyPath == "frame" || givenKeyPath == "center")
            else { return }
        
        keyboardFrame = superViewOfInputAccessory.frame
    }
}
