//
//  HTTPClient.swift
//  Pally Asia
//
//  Created by cl-macmini-117 on 26/09/16.
//  Copyright © 2015 CilckLabs. All rights reserved.
//
import Foundation

enum HttpMethodType: String {
   case GET
   case POST
   case PUT
   case DELETE
}

enum APIErrors: LocalizedError {
   case notConvertible
   case statusCodeNotFound
   case serverThrewError(message: String)
   
   var errorDescription: String? {
      switch self {
      case .serverThrewError(message: let errorMessage):
         return errorMessage
      default:
         return "Something went wrong while connecting to server!"
      }
   }
}

struct NetworkError: LocalizedError {
   var errorDescription: String? {
      return "No Internet Connection"
   }
}

let STATUS_CODE_SUCCESS = 200
let STATUS_UPLOAD_SUCCESS = 201

class HTTPClient {
   
   // MARK: - Properties
   var dataTask: URLSessionDataTask?
   
   // MARK: - Type Properties
   static var shared = HTTPClient()
   
   typealias ServiceResponse = (_ responseObject: Any?, _ error: Error?, _ extendedUrl: String?, _ statusCode: Int?) -> Void
   
   // MARK: - Methods
   func makeSingletonConnectionWith(method: HttpMethodType, showAlert: Bool = true, showAlertInDefaultCase: Bool = true, showActivityIndicator: Bool = true, para: [String: Any]? = nil, baseUrl: String = HippoConfig.shared.baseUrl, extendedUrl: String, callback: @escaping ServiceResponse) {
      
      if dataTask != nil {
         dataTask?.cancel()
      }
      
      dataTask = HTTPClient.makeConcurrentConnectionWith(method: method, showAlert: showAlert, showAlertInDefaultCase: showAlertInDefaultCase, showActivityIndicator: showActivityIndicator, para: para, baseUrl: baseUrl, extendedUrl: extendedUrl, callback: callback)
   }
   
   
   
   // MARK: - Type Methods
   
   ///     Concurrent connection with server.
   
   ///      - parameter method:  Pass Http Method like .GET.
   ///       - parameter showAlert: should show alert like no internet connection etc.
   ///       - parameter showAlertInDefaultCase:  Should show alert in case connection was successful but resulted in error.
   ///       - parameter para: Parameters to send to server.
   ///       - parameter extendedUrl: url afer baseurl
   ///      - parameter callback: responce from server
   
   @discardableResult
   class func makeConcurrentConnectionWith(method: HttpMethodType, showAlert: Bool = false, showAlertInDefaultCase: Bool = false, showActivityIndicator: Bool = false, para: [String: Any]? = nil, baseUrl: String = HippoConfig.shared.baseUrl, extendedUrl: String, callback: @escaping ServiceResponse) -> URLSessionDataTask? {
      
      guard isConnectedToInternet() else {
         let error = NetworkError()
         callback(nil, error, nil, 404)
         return nil
      }
      
      //Request
      var mutableRequest = HTTPClient.createRequestWith(method: method, timeout: 30, baseUrl: baseUrl, extendedUrl: extendedUrl, contentType: "application/json")
      
      showActivityIndicator ? HTTPClient.startAnimatingActivityIndicator(): ()
      
      var additionalParams: [String: Any] = [
         "app_version": fuguAppVersion,
         "device_type": Device_Type_iOS,
         "source": 1
      ]
      
      additionalParams += para ?? [:]
//      if para != nil {
         if let body = try? JSONSerialization.data(withJSONObject: additionalParams, options: []) {
            mutableRequest.httpBody = body
         }
//      }
      
      //DataTask
      let dataTask = HTTPClient.performDataTaskWith(request: mutableRequest, showAlert: showAlert, showAlertInDefaultCase: showAlertInDefaultCase, showActivityIndicator: showActivityIndicator, callback: callback, extendedUrl: extendedUrl)
      
      dataTask.resume()
      
      return dataTask
   }
   
   ///     Multipart form-data connection with server.
   
   ///      - parameter method:  Pass Http Method like .GET.
   ///       - parameter showAlert: should show alert like no internet connection etc.
   ///       - parameter showAlertInDefaultCase:  Should show alert in case connection was successful but resulted in error.
   ///       - parameter para: Parameters to send to server.
   ///       - parameter extendedUrl: url afer baseurl
   ///       - parameter imageList: Dictionary type list whose 'key' represents key of the parameter against which image is to be sent to server and 'value' of respective key is path of the image or array of paths in Directory.
   ///      - parameter callback: responce from server
   
   @discardableResult
   class func makeMultiPartRequestWith(method: HttpMethodType, showAlert: Bool = false, showAlertInDefaultCase: Bool = false, showActivityIndicator: Bool = false, para: [String: Any]? = nil, baseUrl: String = HippoConfig.shared.baseUrl, extendedUrl: String, imageList: [String: Any]? = nil, callback: @escaping ServiceResponse) -> URLSessionDataTask? {
      
      guard isConnectedToInternet() else {
         let error = NetworkError()
         callback(nil, error, nil, 404)
//         showAlert ? ErrorView.showWith(message: error.localizedDescription, removed: nil) : ()
         return nil
      }
      
      let boundary = "Boundary+\(arc4random())\(arc4random())"
      
      showActivityIndicator ? HTTPClient.startAnimatingActivityIndicator(): ()
      
      let timeout: Double = 30 + Double(15 * (imageList?.count ?? 0))
      var mutableRequest = HTTPClient.createRequestWith(method: method, timeout: timeout, baseUrl: baseUrl, extendedUrl: extendedUrl, contentType: "multipart/form-data; boundary=\(boundary)")
      
      var body = Data()
      
      //Image upload
      if imageList != nil {
         for (key, path) in imageList! {
            
            if let arrayOfPaths = path as? [String] {
               for tempPath in arrayOfPaths {
                  body.appendImageWith(key: key, path: tempPath, boundary: boundary)
               }
               continue
            } else if let pathString = path as? String {
               body.appendImageWith(key: key, path: pathString, boundary: boundary)
            } else {
               print("Error -> Not valid path of image in imageList")
            }
            
         }
      }
      
      var additionalParams: [String: Any] = [
         "app_version": fuguAppVersion,
         "device_type": Device_Type_iOS,
         "source": 1
      ]
      
      //appending parameters
//      if para != nil {
      additionalParams += para ?? [:]
      
         for (key, value) in additionalParams {
            
            if value is [String: Any] || value is [Any] {
               
               do {
                  body.append(boundary: boundary)
                  let data  = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted )
                  let jsonString: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                  body.appendParameter(name: key)
                  body.append("\(jsonString)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
               } catch let error as NSError {
                  print("json error: \(error.localizedDescription)")
               }
               
            } else {
               
               body.append(boundary: boundary)
               body.appendParameter(name: key)
               body.append("\(value)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            }
         }
//      }
      
      body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
      
      mutableRequest.httpBody = body
      
      let dataTask = performDataTaskWith(request: mutableRequest, showAlert: showAlert, showAlertInDefaultCase: showAlertInDefaultCase, showActivityIndicator: showActivityIndicator, callback: callback, extendedUrl: extendedUrl)
      dataTask.resume()
    
    return dataTask
   }
   
   
   // MARK: - Private Type Method
   private class func createRequestWith(method: HttpMethodType, timeout: Double, baseUrl: String, extendedUrl: String, contentType: String) -> URLRequest {
      let url = URL(string: baseUrl + extendedUrl)!
      var mutableRequest = URLRequest(url: url)
      mutableRequest.timeoutInterval = timeout
      mutableRequest.httpMethod = method.rawValue
      
      mutableRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
//      if let token = getToken() {
//         mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
//      }
      return mutableRequest
   }
   
   private class func performDataTaskWith(request: URLRequest, showAlert: Bool, showAlertInDefaultCase: Bool, showActivityIndicator: Bool, callback: @escaping ServiceResponse, extendedUrl: String) -> URLSessionDataTask {
      let dataTask = URLSession.shared.dataTask(with: request) {
         (data, urlResponse, error) in
         DispatchQueue.main.async {
            
            if showActivityIndicator {
               HTTPClient.stopAnimatingActivityIndicator()
            }
            
            guard error == nil && data != nil else {
               // connection to server failed
               //TODO:  Do not show alert if dataTask was cancelled
               
//               showAlert == true ? Singleton.sharedInstance.showAlert(ERROR_MESSAGE.NO_INTERNET_CONNECTION): ()
               print(error!.localizedDescription)
               callback(nil, error, extendedUrl, nil)
               return
            }
            
            do {
               let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
               
               //          print(json)
               
               var statusCode = 0
               
               let responseObject = json as? [String: Any]
               if let tempStatusCode = responseObject?["statusCode"] as? NSNumber {
                  //if statusCode is in response from server else getting it from httpResponse
                  statusCode = tempStatusCode.intValue
               } else {
                  guard let httpUrlResponce = urlResponse as? HTTPURLResponse else {
                     callback(nil, APIErrors.statusCodeNotFound, extendedUrl, nil)
                     print("Error -> Status code not found")
                     return
                  }
                  statusCode = httpUrlResponce.statusCode
               }
               
               let message: String = responseObject?["message"] as? String ?? ""
               switch statusCode {
               case 200..<300:
                  callback(json, nil, extendedUrl, statusCode)
                  return
               default:
                  break
//                  showAlertInDefaultCase ? ErrorView.showWith(message: message, isErrorMessage: true, removed: nil) : ()
               }
               
               let error = APIErrors.serverThrewError(message: message)
               callback(json, error, extendedUrl, statusCode)
               
            } catch let jsonError {
               print("parsing error -> \(jsonError)")
               print("Wrong json -> " + (String(data: data!, encoding: .utf8) ?? ""))
               
//               showAlert ? Singleton.sharedInstance.showAlert(ERROR_MESSAGE.SERVER_NOT_RESPONDING) : ()
               
               callback(nil, jsonError, extendedUrl, nil)
            }
         }
      }
      
      return dataTask
   }
   
   private class func isConnectedToInternet() -> Bool {
        return HippoConnection.isNetworkConnected
   }
   
   private class func startAnimatingActivityIndicator() {
//      ActivityIndicator.sharedInstance.showActivityIndicator()
   }
   
   private class func stopAnimatingActivityIndicator() {
//      ActivityIndicator.sharedInstance.hideActivityIndicator()
   }
   
}

// MARK: - Data
private extension Data {
   mutating func append(boundary: String) {
      self.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
   }
   
   mutating func appendContentDepositionWith(key: String, fileName: String) {
      self.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName).jpeg\"\r\n" .data(using: String.Encoding.utf8, allowLossyConversion: true)!)
   }
   
   mutating func appendContentTypeData(type: String) {
      self.append("Content-Type: image/\(type)\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
   }
   
   mutating func appendParameter(name: String) {
      self.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n" .data(using: String.Encoding.utf8, allowLossyConversion: true)!)
   }
   
   mutating func appendImageWith(key: String, path: String, boundary: String) {
      guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
         print("ERROR -> Image file not found")
         return
      }
      self.append(boundary: boundary)
      self.appendContentDepositionWith(key: key, fileName: "Image" + key)
      self.appendContentTypeData(type: "jpg")
      self.append(imageData)
      self.append("\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
   }
}

