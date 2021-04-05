//
//  CustomerUnreadCount.swift
//  Hippo
//
//  Created by Arohi Magotra on 23/03/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation

final
class CustomerUnreadCount{
    
    var unreadHasMapArr = [String : UnreadData]()
  
    func insert(userInfo : [String : Any]){
 
    }
    
    func getData(with muid : String) -> UnreadData? {
        return unreadHasMapArr[muid]
    }
    
}


struct UnreadData {
    let channel_id : Int
    let label_id : Int
    let count : Int
}
