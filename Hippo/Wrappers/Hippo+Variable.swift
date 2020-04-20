//
//  Hippo+Variable.swift
//  Hippo
//
//  Created by Vishal on 10/04/19.
//

import Foundation

class HippoVariable {
    
    #if swift(>=4.2)
    static let didEnterBackgroundNotification = UIApplication.didEnterBackgroundNotification
    static let willTerminateNotification = UIApplication.willTerminateNotification
    static let UITextViewTextDidChange = UITextView.textDidChangeNotification
    static let willResignActiveNotification = UIApplication.willResignActiveNotification
    static let willEnterForegroundNotification = UIApplication.willEnterForegroundNotification
    static let didBecomeActiveNotification = UIApplication.didBecomeActiveNotification
    static let didReceiveMemoryWarningNotification = UIApplication.didReceiveMemoryWarningNotification
    
    static let keyboardFrameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
    static let pickerInfoMediaURL = UIImagePickerController.InfoKey.mediaURL
    static let pickerInfoOriginalImage = UIImagePickerController.InfoKey.originalImage
    static let pickerInfoMediaType = UIImagePickerController.InfoKey.mediaType
    
    static let keyboardWillShowNotification = UIResponder.keyboardWillShowNotification
    static let keyboardWillHideNotification = UIResponder.keyboardWillHideNotification
    static let keyboardDidChangeFrameNotification = UIResponder.keyboardDidChangeFrameNotification
    
    #else
    static let didEnterBackgroundNotification = NSNotification.Name.UIApplicationDidEnterBackground
    static let willTerminateNotification =  NSNotification.Name.UIApplicationWillTerminate
    static let UITextViewTextDidChange = NSNotification.Name.UITextViewTextDidChange
    static let willResignActiveNotification = NSNotification.Name.UIApplicationWillResignActive
    static let willEnterForegroundNotification = NSNotification.Name.UIApplicationWillEnterForeground
    static let didBecomeActiveNotification = NSNotification.Name.UIApplicationDidBecomeActive
    static let didReceiveMemoryWarningNotification = NSNotification.Name.UIApplicationDidReceiveMemoryWarning
    
    static let keyboardFrameEndUserInfoKey = UIKeyboardFrameEndUserInfoKey
    static let pickerInfoMediaURL = UIImagePickerControllerMediaURL
    static let pickerInfoOriginalImage = UIImagePickerControllerOriginalImage
    static let pickerInfoMediaType = UIImagePickerControllerMediaType

    static let keyboardWillShowNotification = NSNotification.Name.UIKeyboardWillShow
    static let keyboardWillHideNotification = NSNotification.Name.UIKeyboardWillHide
    static let keyboardDidChangeFrameNotification = NSNotification.Name.UIKeyboardDidChangeFrame
    #endif
}
