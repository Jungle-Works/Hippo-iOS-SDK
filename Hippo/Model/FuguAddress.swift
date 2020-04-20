//
//  FuguAddress.swift
//  Fugu
//
//  Created by Gagandeep Arora on 14/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
@available(*, deprecated, renamed: "HippoAddress", message: "This class will no longer be available, To Continue migrate to HippoAddress")
@objc public class FuguAddress: NSObject {
    
}


@objc public class HippoAddress: NSObject {
    var addressLine1: String?
    var addressLine2: String?
    var city: String?
    var region: String?
    var country: String?
    var zipCode: String?
    
    public init(addressLine1: String?,
                addressLine2: String?,
                city: String?,
                region: String?,
                country: String?,
                zipCode: String?) {
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.region = region
        self.country = country
        self.zipCode = zipCode
    }
    
    func toJSON() -> [String: Any]? {
        var params = [String: Any]()
        if let addressLine1 = self.addressLine1 { params["address_line1"] = addressLine1 }
        
        if let addressLine2 = self.addressLine2 { params["address_line2"] = addressLine2 }
        
        if let city = self.city { params["city"] = city }
        
        if let region = self.region { params["region"] = region }
        
        if let country = self.country { params["country"] = country }
        
        if let zipcode = self.zipCode { params["zip_code"] = zipcode }
        
        if params.keys.count > 0 { return params }
        return nil
    }
}
