//
//  OfflineChat.swift
//  Fugu
//
//  Created by Gagandeep Arora on 28/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

enum DefaultName: String {
    case unsentMessagesData = "unsent_messages_data"
    case sentMessagesData = "sent_messages_data"
    case conversationData = "fugu_conversation_data"
    case appointmentData = "fugu_appointment_data"
}

struct DefaultKey {
    static let myChatConversations = "Agent_My_Chat_Data"
    static let allChatConversations = "Agent_All_chat_Data"
}
class FuguDefaults: NSObject {
    class func set(value: Any?, forKey keyName: String) {
        if value == nil || ((value as? [Any]) == nil && (value as? [String: Any]) == nil) {
            FuguDefaults.removeObject(forKey: keyName)
            return
        }
        // Get the url of <keyName>.json in document directory
        guard let documentDirectoryUrl = FuguDefaults.fuguContentDirectoryURL() else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("\(keyName).json")
        
        // Transform <value> into data and save it into file
        do {
            let data = try JSONSerialization.data(withJSONObject: value as Any, options: [])
            try data.write(to: fileUrl, options: [])
        } catch { HippoConfig.shared.log.trace(error, level: .customError) }
    }
    
    class func object(forKey keyName: String) -> Any? {
        // Get the url of <keyName>.json in document directory
        guard let documentsDirectoryUrl = FuguDefaults.fuguContentDirectoryURL() else { return nil }
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("\(keyName).json")
        
        // Read data from <keyName>.json file and transform data into an 'Any'
        do {
            let data = try Data(contentsOf: fileUrl, options: [])
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch { HippoConfig.shared.log.trace(error, level: .customError) }
        return nil
    }
    
    class func removeObject(forKey keyName: String) {
        let fileManager = FileManager.default
        guard let documentDirectoryUrl = FuguDefaults.fuguContentDirectoryURL() else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("\(keyName).json")
        
        if fileManager.fileExists(atPath: fileUrl.path) {
            do {
                try fileManager.removeItem(atPath: fileUrl.path)
            } catch let error as NSError { HippoConfig.shared.log.trace(error, level: .customError) }
        }
    }
    
    class func removeAllPersistingData() {
        let fileManager = FileManager.default
        guard let documentDirectoryUrl = FuguDefaults.fuguContentDirectoryURL() else { return }
        var isDir : ObjCBool = true
        if FileManager.default.fileExists(atPath: documentDirectoryUrl.path, isDirectory: &isDir) == true {
            do {
                try fileManager.removeItem(atPath: documentDirectoryUrl.path)
            } catch let error as NSError { HippoConfig.shared.log.trace(error, level: .customError) }
        }
    }
    /// This method is used to get the URL of Hippocontent and create if doesnot exist
    ///
    /// - Returns: It returns the URL of 'FuguContent' folder, return value could be nil in case of any exception
    class func fuguContentDirectoryURL() -> URL? {
        guard var documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        documentsDirectoryUrl = documentsDirectoryUrl.appendingPathComponent("FuguContent", isDirectory: true)
        var isDir : ObjCBool = true
        if FileManager.default.fileExists(atPath: documentsDirectoryUrl.path, isDirectory: &isDir) == false {
            do {
                try FileManager.default.createDirectory(at: documentsDirectoryUrl, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                HippoConfig.shared.log.trace(error, level: .customError)
                return nil
            }
        }
        return documentsDirectoryUrl
    }
    
    /// This method is used to create folder(name of the folder pass through parameters)
    ///
    /// - Parameter folderName: Name of the folder which User want to create
    /// - Returns: It returns the path of created folder or it could be nil in case of any exception
    class func createDirectory(withName folderName: String) -> URL? {
        guard var fuguDirectory = FuguDefaults.fuguContentDirectoryURL() else { return nil }
        fuguDirectory = fuguDirectory.appendingPathComponent(folderName, isDirectory: true)
        var isDir : ObjCBool = true
        if FileManager.default.fileExists(atPath: fuguDirectory.path, isDirectory: &isDir) == false {
            do {
                try FileManager.default.createDirectory(at: fuguDirectory, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                HippoConfig.shared.log.trace(error, level: .customError)
                return nil
            }
        }
        return fuguDirectory
    }
    
    class func fuguImagesDirectory() -> URL? {
        return createDirectory(withName: "fuguImages")
    }
    
    class func totalImagesInImagesFlder() -> Int {
        guard let documentsUrl = FuguDefaults.fuguImagesDirectory() else { return -1 }
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            HippoConfig.shared.log.trace(directoryContents, level: .custom)
            return directoryContents.count
        } catch {
            HippoConfig.shared.log.trace(error.localizedDescription, level: .customError)
            return -1
        }
    }
    
    class func deleteFile(atFilePath filePath: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            do { try fileManager.removeItem(atPath: filePath) }
            catch let error as NSError { HippoConfig.shared.log.trace(error.localizedDescription, level: .customError) }
        }
    }
}
