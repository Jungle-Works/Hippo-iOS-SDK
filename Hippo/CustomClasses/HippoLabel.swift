//
//  HippoLabel.swift
//  HippoChat
//
//  Created by Vishal on 14/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

class HippoLabel: UILabel {
    
}

extension HippoLabel {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) -> Bool {
        
        let readMoreText: String = trailingText + moreText
        let lengthForVisibleString: Int = self.visibleTextLength
        let textCount = text?.count ?? 0
        
        guard lengthForVisibleString > 0, lengthForVisibleString != textCount, let myText = text else {
            return false
        }
        
        let mutableString: String = myText
        
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: myText.count - lengthForVisibleString), with: "")
        
        let readMoreLength: Int = (readMoreText.count)
        
        guard let safeTrimmedString = trimmedString else { return false }
        
        if safeTrimmedString.count <= readMoreLength { return false }
        
        
        
        // "safeTrimmedString.count - readMoreLength" should never be less then the readMoreLength because it'll be a negative value and will crash
        
        let newDisplayedText = safeTrimmedString + readMoreText
        let trimmedForReadMore: String
        
        if doseTextFit(text: newDisplayedText) {
            trimmedForReadMore = newDisplayedText
        } else {
            trimmedForReadMore = (safeTrimmedString as NSString).replacingCharacters(in: NSRange(location: safeTrimmedString.count - readMoreLength, length: readMoreLength), with: "") + trailingText
        }
        
        //        print("---00 this number \(safeTrimmedString.count) should never be less")
        //        print("---00 trimmedForReadMore \(trimmedForReadMore.count)")
        //        print("---00 total length \(self.text?.count ?? -1)")
        //        print("---00 visible length \(lengthForVisibleString)\n")
        
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
        return true
    }
    
    var visibleTextLength: Int {
        
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        guard let myText = self.text else {
            return 0
        }
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: myText, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (myText as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: myText.count - index - 1)).location
                }
            } while index != NSNotFound && index < myText.count && doseTextFit(text: (myText as NSString).substring(to: index))
            return prev
        }
        
        return self.text?.count ?? 0
    }
    
    internal func doseTextFit(text: String) -> Bool {
        let myText = text
        let font: UIFont = self.font
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: myText, attributes: attributes)
        
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        
        return boundingRect.height <= labelHeight
    }
}

