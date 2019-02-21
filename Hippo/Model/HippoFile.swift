//
//  HippoFile.swift
//  Hippo
//
//  Created by Vishal on 16/01/19.
//

import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
import MobileCoreServices
#elseif os(macOS)
import CoreServices
#endif

// MARK: - File
public struct HippoFile: CustomStringConvertible {
    
    private(set) var name: String
    private(set) var fileName: String?
    private(set) var mimeType: String
    private(set) var data: Data
    private(set) var url: URL?
    
    
    public init?(data: Data, name: String, fileName: String, mimeType: String) {
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        self.data = data
    }
    
    public init?(url: URL, name: String, fileName: String, mimeType: String) {
        self.url = url
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        
        guard let fileData = try? Data(contentsOf: url) else {
            print("ERROR -> File not found")
            return nil
        }
        self.data = fileData
    }
    
    public init?(url: URL, name: String) {
        
        guard let fileData = try? Data(contentsOf: url) else {
            print("ERROR -> File not found")
            return nil
        }
        self.data = fileData
        self.url = url
        self.name = name
        self.mimeType = ""
        
        guard let mime = self.findMimeType(for: url) else {
            print("ERROR -> Cannot find mimetype")
            return nil
        }
        self.mimeType = mime
    }
    
    private func findMimeType(for fileUrl: URL) -> String? {
        let fileName = fileUrl.lastPathComponent
        let pathExtension = fileUrl.pathExtension

        guard !fileName.isEmpty, !pathExtension.isEmpty else {
            return nil
        }
        return mimeType(forPathExtension: pathExtension)
    }
    private func mimeType(forPathExtension pathExtension: String) -> String {
        if
            let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }
        
        return "application/octet-stream"
    }
    
    public var description: String {
        return "Name: \(String(describing: name)) fileName: \(String(describing: fileName)) mimeType: \(String(describing: mimeType)) data: \(String(describing: data))"
    }
    
}


extension Data {
    func getFormattedSize() -> String {
        let bytes = Int64(self.count)
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useBytes]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    mutating func appendParameter(key: String, value: Any, boundary: String) {
        
        let finalValue = convertJsonIntoString(json: value)
        
        self.append(boundary: boundary)
        self.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n" .data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        self.append("\(finalValue)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
    }
    private func convertJsonIntoString(json: Any) -> String {
        if json is [String: Any] || json is [Any] {
            if let data  = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) {
                let jsonString: String = String(data: data, encoding: String.Encoding.utf8)!
                return jsonString
            } else {
                return ""
            }
        } else {
            return "\(json)"
        }
    }
    
    mutating func appendFileWith(data: Data, key: String, fileName: String, boundary: String, mimeType: String) {
        self.append(boundary: boundary)
        self.appendContentDepositionWith(key: key, fileName: fileName)
        self.appendContentTypeData(mimeType: mimeType)
        self.append(data)
        self.append("\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
    }
    
    mutating func append(boundary: String) {
        self.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
    }
    
    mutating func appendContentDepositionWith(key: String, fileName: String) {
        self.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n" .data(using: String.Encoding.utf8, allowLossyConversion: true)!)
    }
    
    mutating func appendContentTypeData(mimeType: String) {
        self.append("Content-Type: \(mimeType)\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
    }
}


public class MultipartData {
    let files: [HippoFile]
    let params: [String: Any]?
    let boundary: String
    
    public init(files: [HippoFile], params: [String: Any]?, boundary: String) {
        self.files = files
        self.params = params
        self.boundary = boundary
    }
    
    public func getMultiPartBody() -> Data {
        var body = Data()
        
        let paramData = getParamsInData()
        let fileData = getFileData()
        
        body.append(fileData)
        body.append(paramData)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        
        return body
        
    }
    
    public func getMultiPartHeader() -> [String: String] {
        var header = [String: String]()
        header["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        return header
    }
    
    func getParamsInData() -> Data {
        var paramData = Data()
        
        guard params != nil else {
            return paramData
        }
        
        for (key, value) in params! {
            paramData.appendParameter(key: key, value: value, boundary: boundary)
        }
        
        return paramData
    }
    
    func getFileData() -> Data {
        var fileData = Data()
        
        for file in files {
            fileData.appendFileWith(data: file.data, key: file.name, fileName: file.fileName ?? file.name, boundary: boundary, mimeType: file.mimeType)
        }
        
        return fileData
    }
    
}
