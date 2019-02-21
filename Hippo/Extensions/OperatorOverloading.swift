//
//  OperatorOverloading.swift
//  SDKDemo1
//
//  Created by cl-macmini-117 on 28/11/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation

func += <K, V> (left: inout [K:V], right: [K:V]) {
   for (k, v) in right {
      left[k] = v
   }
}
