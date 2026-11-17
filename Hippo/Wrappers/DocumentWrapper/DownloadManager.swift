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
    /// Latest 0...1 progress per in-flight download, keyed by the caller's (unescaped) URL.
    /// Absent until the first progress tick, and cleared once the download ends either way.
    private var progressWRTUrl = [String: CGFloat]()
    static let urlUserInfoKey = "url"
    static let progressUserInfoKey = "progress"
    
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
        
        // Both blocks are delivered on the main queue by TWRDownloadManager.
        TWRDownloadManager.shared()?.downloadFile(forURL: updatedUrl, withName: nameOfTheFileToBeSavedInCache, inDirectoryNamed: nil, progressBlock: { [weak self] progress in
            self?.downloadProgressed(url: url, progress: progress)
        }, remainingTime: nil, completionBlock: { (success) in
            self.progressWRTUrl[url] = nil
            if success {
                self.fileDownloadedWith(url: url, name: nameOfTheFileToBeSavedInCache)
            } else {
                // Covers both network/HTTP failures and cancelDownloadWith(url:) - either
                // way cells need to drop their spinner/ring and show the download icon again.
                NotificationCenter.default.post(name: .fileDownloadFailed, object: nil, userInfo: [DownloadManager.urlUserInfoKey: url])
            }
        }, enableBackgroundMode: true)
    }

    /// Latest progress for an in-flight download, or nil if none has been reported yet.
    func downloadProgressFor(url: String) -> CGFloat? {
        return progressWRTUrl[url]
    }

    /// Cancels an in-flight download. Ends in a `.fileDownloadFailed` notification.
    func cancelDownloadWith(url: String) {
        let updatedUrl = url.replacingOccurrences(of: " ", with: "%20")
        TWRDownloadManager.shared()?.cancelDownload(forUrl: updatedUrl)
    }

    private func downloadProgressed(url: String, progress: CGFloat) {
        // Progress blocks are queued onto main, so one can land after the download was
        // cancelled or finished - ignore it rather than resurrect a stale entry.
        let updatedUrl = url.replacingOccurrences(of: " ", with: "%20")
        guard progress.isFinite, TWRDownloadManager.shared().isFileDownloading(forUrl: updatedUrl) else { return }
        let previousPercent = progressWRTUrl[url].map { Int($0 * 100) }
        progressWRTUrl[url] = progress
        // URLSession reports every chunk; only notify on a whole-percent change so cells
        // aren't redrawn hundreds of times for one file.
        guard previousPercent != Int(progress * 100) else { return }
        NotificationCenter.default.post(name: .fileDownloadProgress, object: nil, userInfo: [DownloadManager.urlUserInfoKey: url, DownloadManager.progressUserInfoKey: progress])
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
    static let fileDownloadProgress = Notification.Name("FuguFileDownloadProgress")
    static let fileDownloadFailed = Notification.Name("FuguFileDownloadFailed")
}
