//
//  HippoHelper.swift
//  HippoCallClient
//
//  Created by Vishal on 14/11/18.
//  Copyright © 2018 Vishal. All rights reserved.
//

import Foundation


func HippoDelay(_ withDuration: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + withDuration) {
        completion()
    }
}
