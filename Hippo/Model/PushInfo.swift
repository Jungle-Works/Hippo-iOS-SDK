//
//  PushInfo.swift
//  SDKDemo1
//
//  Created by Vishal on 06/06/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation

struct PushInfo {
    var count = 0
    var channelId = -1
    var muid: String?
    var labelId = -1
    
    init(json: [String: Any]) {
        channelId = json["channel_id"] as? Int ?? -1
        muid = json["muid"] as? String
        labelId = json["label_id"] as? Int ?? -1
    }
}
