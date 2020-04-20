//
//  FuguTheme.swift
//  Fugu
//
//  Created by Gagandeep Arora on 28/08/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

@available(*, deprecated, renamed: "HippoTheme", message: "This class will no longer be available, To Continue migrate to HippoTheme")
@objc public class FuguTheme: NSObject {
    public class func defaultTheme() -> HippoTheme { return HippoTheme() }
}

