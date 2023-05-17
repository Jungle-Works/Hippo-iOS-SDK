//
//  OtplessNetworkHelper.swift
//  OtplessSDK
//
//  Created by Otpless on 06/02/23.
//

import Foundation
 class OtplessNetworkHelper {
    var baseurl : String = ""
     var apiRoute = "metaverse"
  typealias NetworkCompletion = (Data?, URLResponse?, Error?) -> Void
  
  static let shared = OtplessNetworkHelper()
  
  func fetchData(method: String , headers: [String: String]? = nil, bodyParams: [String: Any]? = nil, completion: @escaping NetworkCompletion) {
      var request = URLRequest(url:URL(string:baseurl + apiRoute)!)
    request.httpMethod = method
    
      if let headers = headers {
         for (key, value) in headers {
           request.setValue(value, forHTTPHeaderField: key)
         }
       }
       
       if let bodyParams = bodyParams {
         let bodyData = try? JSONSerialization.data(withJSONObject: bodyParams)
         request.httpBody = bodyData
       }
       
       let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
         completion(data, response, error)
       }
       task.resume()
  }
    func setBaseUrl(url: String){
        let urlComponents = URLComponents(string: url)
        if let scheme = urlComponents?.scheme, let host = urlComponents?.host {
            let combinedString = "\(scheme)://\(host)/"
            baseurl = combinedString
        }
    }
}



