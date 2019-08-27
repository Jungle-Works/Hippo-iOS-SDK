//
//  CoreFilesConfig.swift
//  CoreKit
//
//  Created by Vishal on 09/01/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import UIKit

public struct CoreFilesConfig {
    
    public var enabledFileTypes: [CoreMediaTypes] = [CoreMediaTypes.image, .audio, .video, .document, .other]
    public var maxSizeInBytes: UInt = 209715200
    
    public var rotateImageIfRequired: Bool = true
    public var enableResizingImage: Bool = false
    var maxResolution: CGFloat = 1024
    
    
    static var maxSizeAllowedToUploadInMB: UInt {
        let maxSizeInBytes = CoreKit.shared.filesConfig.maxSizeInBytes
        return maxSizeInBytes / (1024 * 1024)
    }
    
    public init() {
        
    }
    
    public init(json: [String: Any]) {
        
    }
    
    static func defaultConfig() -> CoreFilesConfig {
        let config = CoreFilesConfig(json: [:])
        return config
    }
    
    public func toJson() -> [String: Any] {
        var dict = [String: Any]()
        
        let rawSupportedFileTypes = enabledFileTypes.map {$0.rawValue}
        
        dict["supported_file_type"] = rawSupportedFileTypes
        dict["max_upload_file_size"] = self.maxSizeInBytes
        
        return dict
    }
    
    public func checkForDataSelectionLimit(url: URL) -> Bool {
        do {
            let dataCountInMB = try Data.init(contentsOf: url).count/(1024 * 1024)
            return dataCountInMB < CoreFilesConfig.maxSizeAllowedToUploadInMB
        } catch {
            return false
        }
    }
}
