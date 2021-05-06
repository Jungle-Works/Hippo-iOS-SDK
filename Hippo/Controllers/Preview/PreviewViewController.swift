//
//  PreviewViewController.swift
//  HippoAgent
//
//  Created by Arohi Sharma on 10/02/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


class PreviewViewController: UIViewController {
    
    //MARK:- Variables
    
    var image : UIImage?
    var fileType : FileType?
    var sendBtnTapped : ((String?)->())?
    
    //MARK:- IBOutlet
    
    @IBOutlet private var viewNavigation : NavigationBar!
    
    @IBOutlet var textView_PrivateNotes : UITextView!{
        didSet{
            textView_PrivateNotes.delegate = self
        }
    }
    @IBOutlet var imageView_Preview : UIImageView!
    @IBOutlet var label_Placeholder : UILabel!{
        didSet{
            label_Placeholder.text = HippoStrings.messagePlaceHolderText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HippoKeyboardManager.shared.enable = true
        viewNavigation.title = "Preview"
        viewNavigation.leftButton.addTarget(self, action: #selector(action_BackBtn), for: .touchUpInside)
        
        if fileType == .document{
            imageView_Preview.contentMode = .center
            imageView_Preview.image = UIImage(named: "defaultDoc")
        }else{
            imageView_Preview.image = image
            imageView_Preview.contentMode = .scaleAspectFit
        }
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        HippoKeyboardManager.shared.enable = false
        HippoKeyboardManager.shared.keyboardDistanceFromTextField = 0
    }
    
}
extension PreviewViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        label_Placeholder.isHidden = !(textView.text.trimWhiteSpacesAndNewLine().isEmpty)
    }
}

extension PreviewViewController{
    @IBAction func action_SendBtn(){
        sendBtnTapped?(textView_PrivateNotes.text)
        action_BackBtn()
    }
    
    @IBAction func action_BackBtn(){
        self.dismiss(animated: true, completion: nil)
    }
}
