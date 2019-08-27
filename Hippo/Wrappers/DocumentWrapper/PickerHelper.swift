//
//  PickerHelper.swift
//  CoreKit
//
//  Created by Vishal on 09/01/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import UIKit

protocol PickerHelperDelegate: CoreDocumentPickerDelegate, CoreMediaSelectorDelegate {
    func payOptionClicked()
}

class PickerHelper {
    private var documentPicker: CoreDocumentPicker?
    private var imagePicker: CoreMediaSelector?
    private var currentViewController: UIViewController!
    
    weak var delegate: PickerHelperDelegate?
    var enablePayment: Bool = false
    
    init(viewController: UIViewController, enablePayment: Bool) {
        var config = CoreFilesConfig()
        config.enableResizingImage = false
        config.maxSizeInBytes = BussinessProperty.current.maxUploadLimitForBusiness
        CoreKit.shared.filesConfig = config
        
        self.enablePayment = enablePayment
        currentViewController = viewController
    }
    
    func performActionBasedOnGalleryPermission() {
        guard let parsedDelegate = delegate else {
            assertionFailure("Please assign delegate to PickerHelper")
            return
        }
        imagePicker = nil
        imagePicker = CoreMediaSelector(delegate: parsedDelegate)
        imagePicker?.openPhotoLibraryFor(fileName: "Abc", fileTypes: [.image, .video], inViewController: currentViewController)
    }
    
    func performActionBasedOnCameraPermission() {
        guard let parsedDelegate = delegate else {
            assertionFailure("Please assign delegate to PickerHelper")
            return
        }
        imagePicker = nil
        imagePicker = CoreMediaSelector(delegate: parsedDelegate)
        imagePicker?.openCameraFor(fileName: "name", fileTypes: [.image, .video], inViewController: self.currentViewController)
    }
    
    func present(sender: UIView, controller: UIViewController) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let paymentOption = UIAlertAction(title: "Request Payment", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            controller.view.endEditing(true)
            self.delegate?.payOptionClicked()
        })
        
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            controller.view.endEditing(true)
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.performActionBasedOnCameraPermission()
            }
        })
        
        let photoLibraryAction = UIAlertAction(title: "Photo & Video Library", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            controller.view.endEditing(true)
            self.performActionBasedOnGalleryPermission()
        })
        
        let documentAction = UIAlertAction(title: "Document", style: .default) { (_) in
            controller.view.endEditing(true)
            self.documentPicker = CoreDocumentPicker(controller: self.currentViewController)
            self.documentPicker?.delegate = self.delegate
            self.documentPicker?.presentIn(viewController: self.currentViewController, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        
        
        if enablePayment {
            actionSheet.addAction(paymentOption)
        }
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cameraAction)
        
        //Check if iCloud is enabled in capablities
        if FileManager.default.ubiquityIdentityToken != nil {
            if CoreKit.shared.filesConfig.enabledFileTypes.contains(.document) || CoreKit.shared.filesConfig.enabledFileTypes.contains(.other) {            actionSheet.addAction(documentAction)
            }
        }
        
        actionSheet.addAction(cancelAction)
        
        actionSheet.popoverPresentationController?.sourceRect = sender.frame
        actionSheet.popoverPresentationController?.sourceView = sender
        
        
        controller.present(actionSheet, animated: true, completion: nil)
    }
}
