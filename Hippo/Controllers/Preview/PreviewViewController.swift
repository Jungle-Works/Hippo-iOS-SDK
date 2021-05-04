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
    
    //MARK:- IBOutlet
    @IBOutlet var textView_PrivateNotes : UITextView!{
        didSet{
            textView_PrivateNotes.delegate = self
        }
    }
    @IBOutlet var imageView_Preview : UIImageView!
    @IBOutlet var label_Placeholder : UILabel!{
        didSet{
            label_Placeholder.text = HippoStrings.privateMessagePlaceHolder
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if fileType == .document{
            imageView_Preview.contentMode = .center
            imageView_Preview.image = UIImage(named: "defaultDoc")
        }else{
            imageView_Preview.image = image
            imageView_Preview.contentMode = .scaleAspectFit
        }
    
    }
    

}
extension PreviewViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        label_Placeholder.isHidden = !(textView.text.trimWhiteSpacesAndNewLine().isEmpty)
    }
}

extension PreviewViewController{
    @IBAction func action_SendBtn(){
       // sendTapped?(textView_PrivateNotes.text ?? "" == "" ? "N/A" : textView_PrivateNotes.text, mentionListener.mentions)
        action_BackBtn()
    }
    
    @IBAction func action_BackBtn(){
        self.navigationController?.popViewController(animated: true)
    }
}
