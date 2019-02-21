//
//  SelectImageViewController.swift
//  Fugu
//
//  Created by Aditi on 8/29/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

protocol SelectImageViewControllerDelegate: class {
    func selectImageVC(_ selectedImageVC: SelectImageViewController, selectedImage: UIImage)
    func goToConversationViewController()
}

class SelectImageViewController: UIViewController {
    
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    weak var delegate: SelectImageViewControllerDelegate?
    var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectImageView.image = pickedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        selectImageView.image = nil
        print("view will disappear ")
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.delegate?.goToConversationViewController()
    }
    
    @IBAction func sendButton(_ sender: Any) {
        guard let selectedImage = pickedImage else { return }
        self.delegate?.selectImageVC(self, selectedImage: selectedImage)
    }
    
    class func get(delegate: SelectImageViewControllerDelegate, result: CoreMediaSelector.Result) -> SelectImageViewController? {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SelectImageViewController") as? SelectImageViewController else {
            return nil
        }
        return vc
    }
}
