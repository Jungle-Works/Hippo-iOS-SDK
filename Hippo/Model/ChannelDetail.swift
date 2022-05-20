//
//  ChannelDetail.swift
//  Hippo
//
//  Created by soc-admin on 20/05/22.
//

import Foundation

class ChannelDetail: Copying {
    var channelName = ""
    var id = -1
    var isSelected = false
    var isDefaultChannel = true
    var searchableString = ""
    
    required init(original: ChannelDetail) {
        id = original.id
        channelName = original.channelName
        isSelected = original.isSelected
        isDefaultChannel = original.isDefaultChannel
        
        searchableString = channelName.lowercased()
        
    }
    
    init?(json: [String: Any]){
        if let channelName = json["channel_name"] as? String{
            self.channelName = channelName
            self.searchableString = channelName.lowercased()
        }
        if let id = json["id"] as? Int{
            self.id = id
        }
    }
    
    class func parselist(jsonList: [[String: Any]]) -> [ChannelDetail] {
        var list: [ChannelDetail] = []
        
        for each in jsonList {
            guard let obj = ChannelDetail(json: each) else {
                continue
            }
            list.append(obj)
        }
        return list
    }
}

extension ChannelDetail: Storing {
    func getJsonToStore() -> [String: Any]? {
        var json: [String: Any] = [:]
        guard id > 0 else {
            return nil
        }
        json["id"] = id
        json["channel_id"] = id
        json["channel_name"] = channelName
        json["custom_label"] = channelName
        
        return json
    }
}
