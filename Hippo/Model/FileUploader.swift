//
//  FileUploader.swift
//  SDKDemo1
//
//  Created by cl-macmini-117 on 13/12/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation
import AVFoundation

struct FileUploader {
    struct Result {
        let isSuccessful: Bool
        let error: Error?
        let imageUrl: String?
        let imageThumbnailUrl: String?
        let fileUrl: String?
        let status: Int?
    }
    struct RequestParams {
        public let path: String
        public let mimeType: String
        public let fileName: String
        
        public init(path: String, mimeType: String, fileName: String = "") {
            self.path = path
            self.mimeType = mimeType
            
            if fileName.isEmpty {
                self.fileName = URL.init(fileURLWithPath: path).lastPathComponent
            } else {
                self.fileName = fileName
            }
        }
    }
    
    struct FileUploadData {
        var fileUrl : String?
        var fileName : String?
        var fileUploadUrl : String?
        var thumbnailUploadUrl : String?
        var thumbnailUrl :String?
        var thumbnailImage : UIImage?
    }
    
    
    static func uploadFileWith(request: RequestParams, completion: @escaping (FileUploader.Result) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let parameters = getParamsToUploadImageWith(for: request)
            HTTPClient.makeConcurrentConnectionWith(method: .POST, para: parameters, extendedUrl: FuguEndPoints.getUploadFileUrl.rawValue) { (response, error, _, statusCode) in
                if error != nil, let statusCode = (response as? NSDictionary)?.value(forKey: "statusCode") as? Int{
                    if statusCode == 400{
                        completion(Result(isSuccessful: false, error: error, imageUrl: nil, imageThumbnailUrl: nil, fileUrl: nil, status: statusCode))
                    }
                }
                
                var fileData = FileUploadData()
                if let data = (response as? NSDictionary)?.value(forKey: "data") as? NSDictionary{
                    fileData.fileName = data.value(forKey: "file_name") as? String
                    fileData.fileUrl = data.value(forKey: "source_url") as? String
                    fileData.fileUploadUrl = data.value(forKey: "url") as? String
                    fileData.thumbnailUploadUrl = data.value(forKey: "thumbnail_url") as? String
                    fileData.thumbnailUrl = data.value(forKey: "thumbnail_source_url") as? String
                }
                let pathURL = URL.init(fileURLWithPath: request.path)
                guard let dataOfFile = try? Data.init(contentsOf: pathURL, options: []) else {
                    let result = Result(isSuccessful: false, error: nil, imageUrl: nil, imageThumbnailUrl: nil, fileUrl: nil, status: nil)
                    DispatchQueue.main.async {
                        completion(result)
                    }
                    return
                }
                if request.mimeType.contains("video") || request.mimeType.contains("mp4"){
                    fileData.thumbnailImage = generateThumbnail(path: pathURL)
                }
                
                self.hitFileUrlAndUpload(data: dataOfFile, fileData: fileData, request: request, completion: completion)
            }
        }
    }
    
    static func hitFileUrlAndUpload(data: Data, fileData : FileUploadData, request: RequestParams, completion: @escaping (FileUploader.Result) -> Void) {
        guard let url = URL(string: fileData.fileUploadUrl ?? "") else{
            return
        }
        var urlRequest = URLRequest.init(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60)
        
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("binary/octet-stream", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.uploadTask(with: urlRequest, from:data) { (data, response, error) in
            if error != nil {
                let result = Result(isSuccessful: false, error: nil, imageUrl: nil, imageThumbnailUrl: nil, fileUrl: nil, status: nil)
                DispatchQueue.main.async {
                    completion(result)
                }
            }else{
                let result = Result(isSuccessful: true, error: nil, imageUrl: fileData.fileUrl, imageThumbnailUrl: fileData.thumbnailUrl ?? fileData.fileUrl , fileUrl: fileData.fileUrl, status: nil)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }.resume();
        
        if let thumnailUploadUrl = URL(string: fileData.thumbnailUploadUrl ?? ""){
            var urlRequest = URLRequest.init(url: thumnailUploadUrl, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60)
            
            urlRequest.httpMethod = "PUT"
            urlRequest.setValue("binary/octet-stream", forHTTPHeaderField: "Content-Type")
            
            if let thumnailData = fileData.thumbnailImage?.pngData(){
                URLSession.shared.uploadTask(with: urlRequest, from:thumnailData) { (data, response, error) in
                    if error != nil {
                        let result = Result(isSuccessful: false, error: nil, imageUrl: nil, imageThumbnailUrl: nil, fileUrl: nil, status: nil)
                        DispatchQueue.main.async {
                            completion(result)
                        }
                    }else{
                        let result = Result(isSuccessful: true, error: nil, imageUrl: fileData.fileUrl, imageThumbnailUrl: fileData.thumbnailUrl ?? fileData.fileUrl , fileUrl: fileData.fileUrl, status: nil)
                        DispatchQueue.main.async {
                            completion(result)
                        }
                    }
                }.resume();
            }
        }
     
    }
    
    
    
    
    
    
    
    
    private static func getParamsToUploadImageWith(for request: RequestParams) -> [String: Any] {
        
        var params: [String: Any] = ["file_name": request.fileName]
        
        if HippoConfig.shared.appUserType == .customer {
            params["app_secret_key"] = HippoConfig.shared.appSecretKey
        } else if let token = HippoConfig.shared.agentDetail?.fuguToken {
            params["access_token"] = token
        }
        params["allow_all_mime_type"] = true
        
        if HippoProperty.current.restrictMimeType{
            params["restrict_mime_type"] = true
        }else{
            params["restrict_mime_type"] = false
        }
        
        params["file_type"] = request.mimeType
        return params
    }
    static func saveImageInKingfisherCacheFor(thumbnailUrl: String, originalUrl: String, localPath: String) {
        let _ = URL.init(fileURLWithPath: localPath)
        
//        guard let cachedImageData = try? Data.init(contentsOf: pathURL, options: []) else {
//            return
//        }
//        let options = ImageCreatingOptions(scale: 1, duration: 1, preloadAll: true, onlyFirstFrame: false)
//
//        if cachedImageData.kf.imageFormat == .GIF, let cachedImage = KingfisherWrapper<Image>.animatedImage(data: cachedImageData, options: options) {
//            ImageCache.default.store(cachedImage, original: cachedImageData, forKey: thumbnailUrl)
//            ImageCache.default.store(cachedImage, original: cachedImageData, forKey: originalUrl)
//        } else if let cachedImage = UIImage(data: cachedImageData) {
//            ImageCache.default.store(cachedImage, forKey: thumbnailUrl)
//            ImageCache.default.store(cachedImage, forKey: originalUrl)
//        }
    }
}
extension FileUploader{
    
    
    static func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
