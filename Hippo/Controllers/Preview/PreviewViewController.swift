//
//  PreviewViewController.swift
//  HippoAgent
//
//  Created by Arohi Sharma on 10/02/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import CropViewController

class PreviewViewController: UIViewController {
    
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
    @IBOutlet weak var lblDocumentName: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var viewText: UIView!
    
    //MARK:- Properties
    var image : UIImage?
    var fileType : FileType?
    var sendBtnTapped : ((String?, UIImage?)->())?
    var path: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView_PrivateNotes.isHidden = true
        label_Placeholder.isHidden = true
        
        HippoKeyboardManager.shared.enable = true
        viewNavigation.leftButton.addTarget(self, action: #selector(action_BackBtn), for: .touchUpInside)
        textView_PrivateNotes.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        
        if fileType == .document{
            imageView_Preview.contentMode = .center
            imageView_Preview.image = UIImage(named: "defaultDoc", in: FuguFlowManager.bundle, compatibleWith: nil)
            viewNavigation.title = "Document"
            lblDocumentName.text = path?.lastPathComponent
        }else{
            imageView_Preview.image = image
            viewNavigation.title = "Preview"
            imageView_Preview.contentMode = .scaleAspectFit
        }
        
        lblDocumentName.isHidden = !(fileType == .document)
        btnEdit.isHidden = (fileType == .document)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        HippoKeyboardManager.shared.enable = false
        HippoKeyboardManager.shared.keyboardDistanceFromTextField = 0
    }
    
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        return img
    }
    
}

extension PreviewViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        label_Placeholder.isHidden = !(textView.text.isEmpty)
    }
}

extension PreviewViewController{
    @IBAction func action_SendBtn(){
        sendBtnTapped?(textView_PrivateNotes.text.trimWhiteSpacesAndNewLine(), self.image)
        action_BackBtn()
    }
    
    @IBAction func action_BackBtn(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnEditTapped(_ sender: Any) {
        self.presentCropViewController()
    }
    
    func presentCropViewController() {
        guard let image = image else {return}
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .fullScreen
        let nav = UINavigationController(rootViewController: cropViewController)
        present(nav, animated: true, completion: nil)
    }
    
}

extension PreviewViewController : CropViewControllerDelegate{
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        self.image = image
        imageView_Preview.image = image
        self.dismiss(animated: true, completion: nil)
    }
}
