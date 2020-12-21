//
//  DownloadManager.swift
//  Fugu
//
//  Created by Vishal on 10/01/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

class DownloadManager {
    
    static var shared = DownloadManager()
    
    private var urlWRTFileName = [String: String]()
    private var allotedNames = [String]()
    static let urlUserInfoKey = "url"
    
    init() {
        if let urlWRTFileName = FuguDefaults.object(forKey: "DownloadManager.urlWRTFileName") as? [String: String] {
            self.urlWRTFileName = urlWRTFileName
        }
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground), name: HippoVariable.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground), name: HippoVariable.willTerminateNotification, object: nil)
    }
    
    @objc private func appEnteredBackground() {
        FuguDefaults.set(value: urlWRTFileName, forKey: "DownloadManager.urlWRTFileName")
    }
    
    func isFileDownloadedWith(url: String) -> Bool {
        guard let fileName = getFileNameFor(url: url) else {
            return false
        }
        return TWRDownloadManager.shared().fileExists(withName: fileName)
    }
    
    func isFileBeingDownloadedWith(url: String) -> Bool {
        return TWRDownloadManager.shared().isFileDownloading(forUrl: url)
    }
    
    func downloadFileWith(url: String, name: String) {
        
        guard !isFileDownloadedWith(url: url) && !isFileBeingDownloadedWith(url: url) else {
            return
        }
        
        let nameOfTheFileToBeSavedInCache = DownloadManager.generateNameWhichDoestNotExistInCacheDirectoryWith(name: name)
        
        let updatedUrl = url.replacingOccurrences(of: " ", with: "%20")
        
        TWRDownloadManager.shared()?.downloadFile(forURL: updatedUrl, withName: nameOfTheFileToBeSavedInCache, inDirectoryNamed: nil, progressBlock: nil, remainingTime: nil, completionBlock: { (success) in
            if success {
                self.fileDownloadedWith(url: url, name: nameOfTheFileToBeSavedInCache)
            }
        }, enableBackgroundMode: true)
    }
    
    func getLocalPathOf(url: String) -> String? {
        guard let fileName = getFileNameFor(url: url) else {
            return nil
        }
        
        return TWRDownloadManager.shared().localPath(forFile: fileName)
    }
    
    func addAlreadyDownloadedFileWith(name: String, WRTurl url: String) {
        urlWRTFileName[url] = name
    }
    
    
    static func generateNameWhichDoestNotExistInCacheDirectoryWith(name: String) -> String {
        var numberToBeAddedAsSuffix = 0
        while true {
            
            let newName: String
            
            let nameComonents = name.split(separator: ".")
            let componentCount = nameComonents.count
            
            switch numberToBeAddedAsSuffix {
            case 0:
                newName = name
            default:
                if componentCount < 0 {
                    newName = "\(numberToBeAddedAsSuffix)" + name
                } else {
                    let lastComponent = nameComonents.last!
                    var otherComponents = ""
                    for index in 0..<(nameComonents.count - 1) {
                        otherComponents += nameComonents[index]
                    }
                    newName = otherComponents + "(\(numberToBeAddedAsSuffix))" + "." + String(lastComponent)
                }
            }
            
            if !TWRDownloadManager.shared().fileExists(withName: newName) && !DownloadManager.shared.allotedNames.contains(newName) {
                DownloadManager.shared.allotedNames.append(newName)
                return newName
            }
            numberToBeAddedAsSuffix += 1
        }
    }
    
    private func getFileNameFor(url: String) -> String? {
        return urlWRTFileName[url]
    }
    
    private func fileDownloadedWith(url: String, name: String) {
        urlWRTFileName[url] = name
        NotificationCenter.default.post(name: .fileDownloadCompleted, object: nil, userInfo: [DownloadManager.urlUserInfoKey: url])
    }
}

extension Notification.Name {
    static let fileDownloadCompleted = Notification.Name("FuguFileDownloadCompleted")
}
