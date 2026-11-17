//
//  PickerHelper.swift
//  CoreKit
//
//  Created by Vishal on 09/01/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

protocol PickerHelperDelegate: CoreDocumentPickerDelegate, CoreMediaSelectorDelegate {
    func payOptionClicked()
    func shareVideoUrlClicked()
    func shareAudioUrlClicked()
    func sendLocationClicked()
}
extension PickerHelperDelegate {
    func shareVideoUrlClicked(){}
    func shareAudioUrlClicked(){}
}


class PickerHelper {
    private var documentPicker: CoreDocumentPicker?
    private var imagePicker: CoreMediaSelector?
    private var currentViewController: UIViewController!
    
    weak var delegate: PickerHelperDelegate?
    var enablePayment: Bool = false
    var isBotInProgress: Bool = false
    
    init(viewController: UIViewController, enablePayment: Bool) {
        var config = CoreFilesConfig()
        config.enableResizingImage = false
        config.maxSizeInBytes = BussinessProperty.current.maxUploadLimitForBusiness
        CoreKit.shared.filesConfig = config
        
        self.enablePayment = enablePayment
        currentViewController = viewController
    }
    
    /// Asks for photo access first (when not yet decided) and opens the library as soon as
    /// it's granted, so the user doesn't have to tap the option a second time.
    func performActionBasedOnGalleryPermission() {
        PickerHelper.requestPhotoLibraryAccess { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                PickerHelper.showAccessDeniedAlert(message: HippoStrings.photoLibraryAccessMessage, in: self.currentViewController)
                return
            }
            self.openPhotoLibrary()
        }
    }

    /// Same as the gallery flow, for the camera.
    func performActionBasedOnCameraPermission() {
        PickerHelper.requestCameraAccess { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                PickerHelper.showAccessDeniedAlert(message: HippoStrings.cameraAccessMessage, in: self.currentViewController)
                return
            }
            self.openCamera()
        }
    }

    private func openPhotoLibrary() {
        guard let parsedDelegate = delegate else {
            assertionFailure("Please assign delegate to PickerHelper")
            return
        }
        imagePicker = nil
        imagePicker = CoreMediaSelector(delegate: parsedDelegate)
        imagePicker?.openPhotoLibraryFor(fileName: "Abc", fileTypes: [.image, .video], inViewController: currentViewController)
    }

    private func openCamera() {
        guard let parsedDelegate = delegate else {
            assertionFailure("Please assign delegate to PickerHelper")
            return
        }
        imagePicker = nil
        imagePicker = CoreMediaSelector(delegate: parsedDelegate)
        imagePicker?.openCameraFor(fileName: "name", fileTypes: [.image, .video], inViewController: self.currentViewController)
    }

    // MARK: - Permissions

    /// Calls back on the main queue. `.limited` counts as granted - the user picked
    /// which photos to share, and the picker shows them.
    private static func requestPhotoLibraryAccess(_ completion: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async { completion(status == .authorized || status == .limited) }
            }
        default:
            completion(false)
        }
    }

    /// Calls back on the main queue.
    private static func requestCameraAccess(_ completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            completion(false)
        }
    }

    /// "Enable X in Settings" alert with a shortcut to the app's Settings page.
    static func showAccessDeniedAlert(message: String, in controller: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: HippoStrings.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: HippoStrings.openSettings, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        controller.present(alert, animated: true)
    }
    
    func present(sender: UIView, controller: UIViewController, isCreateTicket:Bool = false) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let paymentOption = UIAlertAction(title: HippoStrings.requestPayment, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            controller.view.endEditing(true)
            self.delegate?.payOptionClicked()
        })

      
        let shareVideoUrlOption = UIAlertAction(title: HippoStrings.shareVideoUrl, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            controller.view.endEditing(true)
            self.delegate?.shareVideoUrlClicked()
        })
        
        let shareAudioUrlOption = UIAlertAction(title: HippoStrings.shareAudioUrl, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            controller.view.endEditing(true)
            self.delegate?.shareAudioUrlClicked()
        })
        
        
        let cameraAction = UIAlertAction(title: HippoStrings.camera, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            controller.view.endEditing(true)
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.performActionBasedOnCameraPermission()
            }
        })

        let photoLibraryAction = UIAlertAction(title: HippoStrings.photoLibrary, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            controller.view.endEditing(true)
            self.performActionBasedOnGalleryPermission()
        })

        let documentAction = UIAlertAction(title: HippoStrings.document, style: .default) { (_) in
            controller.view.endEditing(true)
            self.documentPicker = CoreDocumentPicker(controller: self.currentViewController)
            self.documentPicker?.delegate = self.delegate
            self.documentPicker?.presentIn(viewController: self.currentViewController, completion: nil)
        }

        let cancelAction = UIAlertAction(title: HippoStrings.cancel, style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })


        if enablePayment {
            actionSheet.addAction(paymentOption)
        }
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cameraAction)
        if BussinessProperty.current.isCallInviteEnabled ?? false && isCreateTicket == false {
            if !isBotInProgress{
                actionSheet.addAction(shareVideoUrlOption)
                actionSheet.addAction(shareAudioUrlOption)
            }
        }
//        //Check if iCloud is enabled in capablities
//        if FileManager.default.ubiquityIdentityToken != nil {
//            if CoreKit.shared.filesConfig.enabledFileTypes.contains(.document) || CoreKit.shared.filesConfig.enabledFileTypes.contains(.other) {            actionSheet.addAction(documentAction)
//            }
//        }
        if !isCreateTicket {
            actionSheet.addAction(documentAction)
        }

        actionSheet.addAction(cancelAction)

        actionSheet.popoverPresentationController?.sourceRect = sender.frame
        actionSheet.popoverPresentationController?.sourceView = sender


        controller.present(actionSheet, animated: true, completion: nil)
    
        
    }
    
    func presentCustomActionSheet(sender: UIView, controller: UIViewController, openType: String) {

        switch openType{
        case HippoStrings.requestPayment:
            controller.view.endEditing(true)
            self.delegate?.payOptionClicked()
        case HippoStrings.shareAudioUrl:
            self.delegate?.shareAudioUrlClicked()
        case HippoStrings.shareVideoUrl:
            self.delegate?.shareVideoUrlClicked()
        case HippoStrings.camera:
            controller.view.endEditing(true)
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.performActionBasedOnCameraPermission()
            }
        case HippoStrings.photoLibrary:
            controller.view.endEditing(true)
            self.performActionBasedOnGalleryPermission()
        case HippoStrings.document:
            controller.view.endEditing(true)
            HippoConfig.shared.HideJitsiView()
            self.documentPicker = CoreDocumentPicker(controller: self.currentViewController)
            self.documentPicker?.delegate = self.delegate
            self.documentPicker?.presentIn(viewController: self.currentViewController, completion: nil)
        case "Send Current Location":
            self.delegate?.sendLocationClicked()  
        default :
            print("default")
        }
//        if enablePayment {
//            actionSheet.addAction(paymentOption)
//        }
//        actionSheet.addAction(photoLibraryAction)
//        actionSheet.addAction(cameraAction)
//        //Check if iCloud is enabled in capablities
//        if FileManager.default.ubiquityIdentityToken != nil {
//            if CoreKit.shared.filesConfig.enabledFileTypes.contains(.document) || CoreKit.shared.filesConfig.enabledFileTypes.contains(.other) {            actionSheet.addAction(documentAction)
//            }
//        }
//        actionSheet.addAction(cancelAction)
//        actionSheet.popoverPresentationController?.sourceRect = sender.frame
//        actionSheet.popoverPresentationController?.sourceView = sender
//        controller.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
}
