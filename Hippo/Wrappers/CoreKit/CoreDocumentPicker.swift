//
//  DocumentPicker.swift
//  CoreKit
//
//  Created by Vishal on 09/01/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

public protocol CoreDocumentPickerDelegate: AnyObject {
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
        
        var contentTypes = [UTType]()

        if CoreKit.shared.filesConfig.enabledFileTypes.contains(.document) {
            contentTypes += [.pdf, .text, .zip, .commaSeparatedText, .presentation, .spreadsheet, .data]
        }
        if CoreKit.shared.filesConfig.enabledFileTypes.contains(.audio) {
            contentTypes += [.audio, .mp3, .midi, .mpeg4Audio, .wav]
            if let aac = UTType("public.aac-audio") { contentTypes.append(aac) }
        }
        if CoreKit.shared.filesConfig.enabledFileTypes.contains(.video) {
            contentTypes.append(.movie)
        }
        if CoreKit.shared.filesConfig.enabledFileTypes.contains(.other) {
            contentTypes += [.sourceCode, .item, .executable, .font]
            if let script = UTType("public.script") { contentTypes.append(script) }
        }
        picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
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
        guard let firstURL = urls.first else { return }
        guard CoreKit.shared.filesConfig.checkForDataSelectionLimit(url: firstURL) == true else {
            DispatchQueue.main.async {
                self.delegate?.fileSelectedWithBiggerSize(maxSizeAllowed: CoreFilesConfig.maxSizeAllowedToUploadInMB)
            }
            return
        }

        DispatchQueue.main.async {
            self.picker.dismiss(animated: true, completion: nil)
            self.delegate?.didPickDocumentWith(url: firstURL)
        }
    }
    
}
