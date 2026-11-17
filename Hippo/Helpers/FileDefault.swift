//
//  FileDefault.swift
//  Hippo
//
//  Created by Neha Vaish on 23/02/24.
//

import Foundation

extension String {
    func removeDot() -> String {
        return self.replacingOccurrences(of: ".", with: "")
    }
}
class FileDefault {
    let folderName: String
    let ext: String

    init(folderName: String, ext: String) {
        self.folderName = folderName.isEmpty ? "Hippo" : folderName
        self.ext = ext.isEmpty ? "hippo" : ext.removeDot()
    }


    func contentDirectoryURL() -> URL? {
        guard var documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        documentsDirectoryUrl = documentsDirectoryUrl.appendingPathComponent(folderName, isDirectory: true)
        var isDir : ObjCBool = true
        if FileManager.default.fileExists(atPath: documentsDirectoryUrl.path, isDirectory: &isDir) == false {
            do {
                try FileManager.default.createDirectory(at: documentsDirectoryUrl, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
                return nil
            }
        }
        return documentsDirectoryUrl
    }

    func set(value: Any?, forKey keyName: String) {
        if value == nil || ((value as? [Any]) == nil && (value as? [String: Any]) == nil) {
            removeObject(forKey: keyName)
            return
        }
        // Get the url of <keyName>.json in document directory
        guard let documentDirectoryUrl = contentDirectoryURL() else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("\(keyName).\(ext)")

        // Transform <value> into data and save it into file
        do {
            let data = try JSONSerialization.data(withJSONObject: value as Any, options: [])
            try data.write(to: fileUrl, options: [])
        } catch { print(error) }
    }

    func object(forKey keyName: String) -> Any? {
        // Get the url of <keyName>.json in document directory
        guard let documentsDirectoryUrl = contentDirectoryURL() else { return nil }
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("\(keyName).\(ext)")

        // Read data from <keyName>.json file and transform data into an 'Any'
        do {
            let data = try Data(contentsOf: fileUrl, options: [])
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch { print(error) }
        return nil
    }
    func removeObject(forKey keyName: String) {
        let fileManager = FileManager.default
        guard let documentDirectoryUrl = contentDirectoryURL() else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("\(keyName).\(ext)")

        if fileManager.fileExists(atPath: fileUrl.path) {
            do {
                try fileManager.removeItem(atPath: fileUrl.path)
            } catch let error as NSError { print(error.debugDescription) }
        }
    }
    func removeAllPersistingData() {
        let fileManager = FileManager.default
        guard let documentDirectoryUrl = contentDirectoryURL() else { return }
        var isDir : ObjCBool = true
        if FileManager.default.fileExists(atPath: documentDirectoryUrl.path, isDirectory: &isDir) == true {
            do {
                try fileManager.removeItem(atPath: documentDirectoryUrl.path)
            } catch let error as NSError { print(error.debugDescription) }
        }
    }
    func getFilePath(keyName: String) -> URL? {
        guard let documentDirectoryUrl = contentDirectoryURL() else {
            return nil
        }
        return documentDirectoryUrl.appendingPathComponent("\(keyName).\(ext)")
    }
    func getAllFiles() -> [URL]? {
        guard let documentDirectoryUrl = contentDirectoryURL() else {
            return nil
        }
        do {
            return try FileManager.default.contentsOfDirectory(at: documentDirectoryUrl, includingPropertiesForKeys: nil, options: .skipsPackageDescendants)
        } catch let error as NSError {
            assertionFailure(error.localizedDescription)
        }
       return nil

    }

}
