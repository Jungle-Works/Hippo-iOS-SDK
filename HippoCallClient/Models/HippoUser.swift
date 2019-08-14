//
//  HippoUser.swift
//  HippoCallClient
//
//  Created by Vishal on 30/10/18.
//

import Foundation

public class HippoUser {
    var fullName: String
    var imageThunbnailUrl: String
    var userId: Int?
    
    public init?(json: [String: Any]) {
        fullName = json["full_name"] as? String ?? ""
        imageThunbnailUrl = json["thumbnail_url"] as? String ?? json["user_image"] as? String ?? json["image_url"] as? String ?? ""
        userId = json["user_id"] as? Int ?? -222
        
        fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if fullName.isEmpty {
            fullName = "User"
        }
    }
    public init?(name: String, userID: Int, imageURL: String?) {
        fullName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        imageThunbnailUrl = imageURL ?? ""
        userId = userID
        
        if fullName.isEmpty {
            fullName = "User"
        }
    }
}

extension HippoUser: CallPeer {
    public var name: String {
        return fullName
    }
    
    public var image: String {
        return imageThunbnailUrl
    }
    
    public var peerId: String {
        return (userId ?? -1).description
    }
}
