//
//  UITextView+Properties.swift
//  Fugu
//
//  Created by Gagandeep Arora on 15/06/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation
import UIKit

protocol HippoMessageTextViewImageDelegate: class {
    func imagePasted()
}

class HippoMessageTextView: UITextView {
    // MARK: - Properties
    weak var imagePasteDelegate: HippoMessageTextViewImageDelegate?
    
    var privateText: NSAttributedString = NSAttributedString(string: "")
    var normalText: NSAttributedString = NSAttributedString(string: "")
    var isPrivateMode: Bool = false {
        didSet {
            updateDataAsPerMode()
        }
    }
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        textAlignment = .left
        contentInset.top = 12
        contentInset.bottom = 0
        text = ""
    }
    
    private func updateDataAsPerMode() {
        isPrivateMode ? setPropertyForPrivateMode() : setPropertyForNormalMode()
    }
    private func setPropertyForPrivateMode() {
//        normalText = attributedText
        attributedText = privateText
    }
    
    private func setPropertyForNormalMode() {
//        privateText = attributedText
        attributedText = normalText
    }
    
    // MARK: - Methods
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) && UIPasteboard.general.hasImages {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func paste(_ sender: Any?) {
        if UIPasteboard.general.hasImages {
            imagePasteDelegate?.imagePasted()
        } else {
            super.paste(sender)
        }
    }
    
}
