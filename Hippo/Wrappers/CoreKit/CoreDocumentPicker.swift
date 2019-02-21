//
//  DocumentPicker.swift
//  CoreKit
//
//  Created by Vishal on 09/01/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import UIKit
import MobileCoreServices

public protocol CoreDocumentPickerDelegate: class {
    func didPickDocumentWith(url: URL)
    func fileSelectedWithBiggerSize(maxSizeAllowed: UInt)
}

public class CoreDocumentPicker: NSObject, UIDocumentPickerDelegate {
    fileprivate var picker: UIDocumentPickerViewController
    fileprivate var currentController: UIViewController?
    
    public weak var delegate: CoreDocumentPickerDelegate?
    
    // MARK: Intializer
    public init(controller: UIViewController) {
        currentController = controller
        
        var documentType = [String]()
        
        if CoreKit.shared.filesConfig.enabledFileTypes.contains(.document) {
            documentType = [kUTTypePDF, kUTTypeText, kUTTypeZipArchive, kUTTypeCommaSeparatedText, kUTTypePresentation, kUTTypeSpreadsheet] as [String]
            documentType.append("public.data")
        }
        
        if CoreKit.shared.filesConfig.enabledFileTypes.contains(.audio) {
            documentType.append(kUTTypeAudio as String)
            documentType.append(kUTTypeMP3 as String)
            documentType.append(kUTTypeMIDIAudio as String)
            documentType.append(kUTTypeMPEG4Audio as String)
            documentType.append(kUTTypeAppleProtectedMPEG4Audio as String)
            documentType.append(kUTTypeWaveformAudio as String)
            documentType.append("public.audio")
        }
        
        if CoreKit.shared.filesConfig.enabledFileTypes.contains(.video) {
            documentType.append(kUTTypeMovie as String)
        }
        if CoreKit.shared.filesConfig.enabledFileTypes.contains(.other) {
            documentType.append("public.source-code")
            documentType.append("public.item")
            documentType.append(" public.script")
            documentType.append("public.executable")
            documentType.append("public.font")
        }
        picker = UIDocumentPickerViewController.init(documentTypes: documentType, in: .import)
        super.init()
        
        picker.delegate = self
    }
    
    // MARK: - METHODS
    public func presentIn(viewController: UIViewController, completion: (() -> Void)?) {
        viewController.present(picker, animated: true, completion: completion)
    }
    public func dismiss(animated: Bool) {
        picker.dismiss(animated: animated, completion: nil)
    }
    
    // MARK: - UIDocumentPickerDelegate
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        
        if #available(iOS 10, *) {
            guard CoreKit.shared.filesConfig.checkForDataSelectionLimit(url: url) == true else {
                DispatchQueue.main.async {
                    self.delegate?.fileSelectedWithBiggerSize(maxSizeAllowed: CoreKit.shared.filesConfig.maxSizeInBytes)
                }
                return
            }
            
            picker.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                self.delegate?.didPickDocumentWith(url: url)
            }
        }
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard CoreKit.shared.filesConfig.checkForDataSelectionLimit(url: urls.first!) == true else {
            DispatchQueue.main.async {
                self.delegate?.fileSelectedWithBiggerSize(maxSizeAllowed: CoreFilesConfig.maxSizeAllowedToUploadInMB)
            }
            return
        }
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            self.delegate?.didPickDocumentWith(url: urls.first!)
        }
    }
    
}
