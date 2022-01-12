//
//  VideoSDKTest.swift
//  Hippo-Hippo
//
//  Created by soc-admin on 22/12/21.
//

import UIKit
import Video

class VideoSDKTest: UIViewController {
    
    let LOCAL_SERVER_URL = "http://192.168.0.101:9000"

    @IBOutlet weak var meetIdTf: UITextField!
    @IBOutlet weak var nameTf: UITextField!
    @IBAction func btnjoin(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    

}


class APIService {

    class func getToken(completion: @escaping (Result<String, Error>) -> Void) {
        var url = URL(string: LOCAL_SERVER_URL)!
        url = url.appendingPathComponent("get-token")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let token = data.toJSON()["token"] as? String {
                completion(.success(token))
            } else if let err = error {
                completion(.failure(err))
            }
        }
        .resume()
    }

    class func createMeeting(token: String, completion: @escaping (Result<String, Error>) -> Void) {
        var url = URL(string: LOCAL_SERVER_URL)!
        url = url.appendingPathComponent("create-meeting")

        let params = ["token": token]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let meetingId = data.toJSON()["meetingId"] as? String {
                completion(.success(meetingId))
            } else if let err = error {
                completion(.failure(err))
            }
        }
        .resume()
    }
}
