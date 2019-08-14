//
//  CallPeer.swift
//  Hippo
//
//  Created by Asim on 16/10/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import Foundation

public protocol CallPeer: CallerInfo {
   var peerId: String { get }
}
public protocol CallerInfo {
    var name: String { get }
    var image: String { get }
}
