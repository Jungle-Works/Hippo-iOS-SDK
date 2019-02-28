//
//  FuguImageUploader.swift
//  SDKDemo1
//
//  Created by cl-macmini-117 on 13/12/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

struct FuguImageUploader {
   struct Result {
      let isSuccessful: Bool
      let error: Error?
      let imageUrl: String?
      let imageThumbnailUrl: String?
   }
   
   private init() {
   }
   
   static func uploadImageWith(path: String, completion: @escaping (FuguImageUploader.Result) -> Void) {
      
      let params = getParamsToUploadImageWith()
      let imageParam = ["file": path]
      
      let endPoint = FuguEndPoints.API_UPLOAD_FILE.rawValue
      HTTPClient.makeMultiPartRequestWith(method: .POST, para: params, extendedUrl: endPoint, imageList: imageParam) { (responseObject, error, _, _) in
         
         guard let response = responseObject as? [String: Any],
            let data = response["data"] as? [String: Any],
            let imageUrl = data["image_url"] as? String,
            let thumbnailUrl = data["thumbnail_url"] as? String else {
               let result = Result(isSuccessful: false, error: error, imageUrl: nil, imageThumbnailUrl: nil)
               completion(result)
               return
         }
         
         let result = Result(isSuccessful: true, error: nil, imageUrl: imageUrl, imageThumbnailUrl: thumbnailUrl)
         completion(result)
      }
   }

   private static func getParamsToUploadImageWith() -> [String: Any] {
      var params = [String: Any]()
      params["app_secret_key"] = HippoConfig.shared.appSecretKey
      params["file_type"] = "image"
      return params
   }
}
