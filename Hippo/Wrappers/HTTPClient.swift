//
//  HTTPClient.swift
//  Pally Asia
//
//  Created by cl-macmini-117 on 26/09/16.
//  Copyright © 2015 CilckLabs. All rights reserved.
//
import UIKit

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
            return HippoStrings.somethingWentWrong
        }
    }
}

struct NetworkError: LocalizedError {
    var errorDescription: String? {
        return HippoStrings.noNetworkConnection
    }
}

let STATUS_CODE_SUCCESS = 200
let STATUS_UPLOAD_SUCCESS = 201

class HTTPClient {
    
    enum EncodingType {
        case json
        case url
        
        func getContentType() -> String {
            switch  self {
            case .url:
                return "application/x-www-form-urlencoded"
            case .json:
                return "application/json"
            }
        }
    }
    
    // MARK: - Properties
    var dataTask: URLSessionDataTask?
    private var retries = 0
    private var curlUrl = "https://chat.googleapis.com/v1/spaces/AAAAELI_7Kw/messages"
    
    var singletonDataTask: [String: URLSessionDataTask?] = [:]
    
    
    // MARK: - Type Properties
    public static var shared = HTTPClient()
    
    typealias ServiceResponse = (_ responseObject: Any?, _ error: Error?, _ extendedUrl: String?, _ statusCode: Int?) -> Void
    
    // MARK: - Methods
    func cancelDataTaskFor(identifier: String) {
        if let tempDataTask = singletonDataTask[identifier] {
            tempDataTask?.cancel()
        }
        singletonDataTask[identifier] = nil
    }
    func makeSingletonConnectionWith(method: HttpMethodType, identifier: String, showAlert: Bool = true, showAlertInDefaultCase: Bool = true, showActivityIndicator: Bool = true, para: [String: Any]? = nil, baseUrl: String = HippoConfig.shared.baseUrl, extendedUrl: String, callback: @escaping ServiceResponse) {
        
        if let tempDataTask = singletonDataTask[identifier] {
            tempDataTask?.cancel()
        }
        
        let newDataRequest = HTTPClient.makeConcurrentConnectionWith(method: method, showAlert: showAlert, showAlertInDefaultCase: showAlertInDefaultCase, showActivityIndicator: showActivityIndicator, para: para, baseUrl: baseUrl, extendedUrl: extendedUrl, callback: callback)
        singletonDataTask[identifier] = newDataRequest
    }
    
    class func makeThirpartyCall(method: HttpMethodType, enCodingType: EncodingType = .json, showAlert: Bool = false, showAlertInDefaultCase: Bool = false, showActivityIndicator: Bool = false, para: [String: Any]? = nil, baseUrl: String = HippoConfig.shared.baseUrl, extendedUrl: String, callback: @escaping ServiceResponse) -> URLSessionDataTask? {
        
        guard isConnectedToInternet() else {
            let error = NetworkError()
            callback(nil, error, nil, 404)
            return nil
        }
        
        //Request
        let contentType: String = enCodingType.getContentType()
        var mutableRequest = HTTPClient.createRequestWith(method: method, timeout: 60, baseUrl: baseUrl, extendedUrl: extendedUrl, contentType: contentType)
        
        showActivityIndicator ? HTTPClient.startAnimatingActivityIndicator(): ()
        
        let parsedParam = para ?? [:]
        if !parsedParam.isEmpty {
            if let body = try? JSONSerialization.data(withJSONObject: parsedParam, options: []) {
                mutableRequest.httpBody = body
            }
        }
        //DataTask
        let dataTask = HTTPClient.performDataTaskWith(request: mutableRequest, showAlert: showAlert, showAlertInDefaultCase: showAlertInDefaultCase, showActivityIndicator: showActivityIndicator, callback: callback, extendedUrl: extendedUrl)
        dataTask.resume()
        
        return dataTask
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
    class func makeConcurrentConnectionWith(method: HttpMethodType, enCodingType: EncodingType = .json, showAlert: Bool = false, showAlertInDefaultCase: Bool = false, showActivityIndicator: Bool = false, para: [String: Any]? = nil, baseUrl: String = HippoConfig.shared.baseUrl, extendedUrl: String, callback: @escaping ServiceResponse) -> URLSessionDataTask? {
        
        guard isConnectedToInternet() else {
            let error = NetworkError()
            callback(nil, error, nil, 404)
            return nil
        }
        var additionalParams = [
                "app_version": fuguAppVersion,
                "device_type": Device_Type_iOS,
                "source_type": SourceType.SDK.rawValue,
                "device_id":  UIDevice.current.identifierForVendor?.uuidString ?? 0,
                "device_details": AgentDetail.getDeviceDetails(),
                "lang" : getCurrentLanguageLocale()
            ] as [String : Any]
        
        additionalParams += para ?? [:]
        
        var newExtendedURL = extendedUrl
        
        switch enCodingType {
        case .json:
            break
        case .url:
            let queryString = "?" + query(additionalParams)
            newExtendedURL += queryString
        }
        
        //Request
        let contentType: String = enCodingType.getContentType()
        var mutableRequest = HTTPClient.createRequestWith(method: method, timeout: 60, baseUrl: baseUrl, extendedUrl: newExtendedURL, contentType: contentType)
        
        showActivityIndicator ? HTTPClient.startAnimatingActivityIndicator(): ()
        
        
        switch enCodingType {
        case .json:
            if let body = try? JSONSerialization.data(withJSONObject: additionalParams, options: []) {
                mutableRequest.httpBody = body
            }
        case .url:
            break
        }
        
        
        
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
    class func makeMultiPartRequestWith(method: HttpMethodType, showAlert: Bool = false, showAlertInDefaultCase: Bool = false, showActivityIndicator: Bool = false, para: [String: Any]? = nil, baseUrl: String = HippoConfig.shared.baseUrl, extendedUrl: String, fileList: [HippoFile], callback: @escaping ServiceResponse) -> URLSessionDataTask? {
        
        guard isConnectedToInternet() else {
            let error = NetworkError()
            callback(nil, error, nil, 404)
            return nil
        }
        let boundary = "Boundary+\(arc4random())\(arc4random())"
        showActivityIndicator ? HTTPClient.startAnimatingActivityIndicator(): ()
        
        var additionalParams: [String: Any] = [
            "app_version": fuguAppVersion,
            "device_type": Device_Type_iOS,
            "source_type": SourceType.SDK.rawValue,
            "device_id":  UIDevice.current.identifierForVendor?.uuidString ?? 0,
            "device_details": AgentDetail.getDeviceDetails(),
            "lang" : getCurrentLanguageLocale()
        ]
        
        //appending parameters
        additionalParams += para ?? [:]
        
        let timeout: Double = 30 + Double(15 * (fileList.count))
        var mutableRequest = HTTPClient.createRequestWith(method: method, timeout: timeout, baseUrl: baseUrl, extendedUrl: extendedUrl, contentType: "multipart/form-data; boundary=\(boundary)")
        
        
        
        let multipartData = MultipartData(files: fileList, params: para, boundary: boundary)
        
        let body = multipartData.getMultiPartBody()
        
        mutableRequest.httpBody = body
        
        let dataTask = performDataTaskWith(request: mutableRequest, showAlert: showAlert, showAlertInDefaultCase: showAlertInDefaultCase, showActivityIndicator: showActivityIndicator, callback: callback, extendedUrl: extendedUrl)
        
        dataTask.resume()
        return dataTask
        
    }
    
    private class func sendCurl(request : URLRequest, code : Int){
        let parameters = "{text : \"appversion = \(fuguAppVersion) app_secret_key = \(HippoConfig.shared.appSecretKey) API = \(request.url) Date = \(Date()) \"}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://chat.googleapis.com/v1/spaces/AAAAELI_7Kw/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=X_4MUG2HTaTMSet0c8IwsAmWlAv25dPsrU5ey2qj6Cs%3D")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
        }

        task.resume()

    }
    
    
    
    
    // MARK: - Private Type Method
    private class func createRequestWith(method: HttpMethodType, timeout: Double, baseUrl: String, extendedUrl: String, contentType: String) -> URLRequest {
        let url = URL(string: baseUrl + extendedUrl)!
        var mutableRequest = URLRequest(url: url)
        mutableRequest.timeoutInterval = timeout
        mutableRequest.httpMethod = method.rawValue
        
        mutableRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        return mutableRequest
    }
    
    //   private class func shouldRetryFor(error: Error) -> Bool {
    //        let nserror = error as NSError
    //        return nserror.code == -1005 && retries == 0
    //   }
    
    
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
                    //                if let parsedError = error, self.shouldRetryFor(error: parsedError) {
                    //                    self.retries += 1
                    //                    //                            print("====> timeline Error \(dataRequest.request?.url) ---\(response.timeline) \(error)!!!!!!!!!!!!!!!!!!!!!!!!!!")
                    //                    self.startRequest(httpModelOn: httpModelOn)
                    //                    return
                    //                }
                    
                    //               showAlert == true ? Singleton.sharedInstance.showAlert(ERROR_MESSAGE.NO_INTERNET_CONNECTION): ()
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
                    if HippoConfig.shared.baseUrl == SERVERS.devUrl{
                        sendCurl(request: request, code: statusCode)
                    }
                    HippoConfig.shared.log.error("API RESPONSE: ---url: \(urlResponse?.url?.absoluteString ?? "NO URL"), ---data: \(data?.count ?? -1) ---Error: \(error?.localizedDescription ?? "no error")", level: .custom)
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
        return FuguNetworkHandler.shared.isNetworkConnected
    }
    
    private class func startAnimatingActivityIndicator() {
        //      ActivityIndicator.sharedInstance.showActivityIndicator()
    }
    
    private class func stopAnimatingActivityIndicator() {
        //      ActivityIndicator.sharedInstance.hideActivityIndicator()
    }
    
    
}

extension HTTPClient {
    public class func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    class func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value is Bool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    ///
    /// - parameter string: The string to be percent-escaped.
    ///
    /// - returns: The percent-escaped string.
    class func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        
        return escaped
    }
}

// MARK: - Data
private extension Data {
    
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

