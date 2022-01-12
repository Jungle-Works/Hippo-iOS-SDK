//
//  VideoSdkHandler.swift
//  Hippo
//
//  Created by soc-admin on 23/12/21.
//

//import UIKit
//
//class VideoSdkHandler: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        VideoSDK.config()
//
//        // Do any additional setup after loading the view.
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
//
//
//
//// Update server url here.
//let LOCAL_SERVER_URL = "http://192.168.0.101:9000"
//
//class APIService {
//
//    class func getToken(completion: @escaping (Result<String, Error>) -> Void) {
//        var url = URL(string: LOCAL_SERVER_URL)!
//        url = url.appendingPathComponent("get-token")
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data, let token = data.toJSON()["token"] as? String {
//                completion(.success(token))
//            } else if let err = error {
//                completion(.failure(err))
//            }
//        }
//        .resume()
//    }
//
//    class func createMeeting(token: String, completion: @escaping (Result<String, Error>) -> Void) {
//        var url = URL(string: LOCAL_SERVER_URL)!
//        url = url.appendingPathComponent("create-meeting")
//
//        let params = ["token": token]
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data, let meetingId = data.toJSON()["meetingId"] as? String {
//                completion(.success(meetingId))
//            } else if let err = error {
//                completion(.failure(err))
//            }
//        }
//        .resume()
//    }
//}
