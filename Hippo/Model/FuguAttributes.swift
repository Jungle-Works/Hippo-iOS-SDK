//
//  FuguAttributes.swift
//  Fugu
//
//  Created by Gagandeep Arora on 14/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
import CoreLocation
import Darwin

@available(*, deprecated, renamed: "HippoAttributes", message: "This class will no longer be available, To Continue migrate to HippoAttributes")
public class FuguAttributes: NSObject {
    
}

@objc public class HippoAttributes: NSObject {
    public var userLocation: CLLocationCoordinate2D?
    var address: HippoAddress?
    var ipAddress: String? {
        var temp = [CChar](repeating: 0, count: 255)
        enum SocketType: Int32 {
            case  SOCK_STREAM = 0, SOCK_DGRAM, SOCK_RAW
        }
        // host name
        gethostname(&temp, temp.count)
        // create addrinfo based on hints
        // if host name is nil or "" we can connect on localhost
        // if host name is specified ( like "computer.domain" ... "My-MacBook.local" )
        // than localhost is not aviable.
        // if port is 0, bind will assign some free port for us
        
        var port: UInt16 = 0
        let hosts = [String(cString: temp)]//["localhost", String(cString: temp)]
        var hints = addrinfo()
        hints.ai_flags = 0
        hints.ai_family = PF_UNSPEC
        
        for host in hosts {
           // print("\n\(host)")
            
            // retrieve the info
            // getaddrinfo will allocate the memory, we are responsible to free it!
            var info: UnsafeMutablePointer<addrinfo>?
            defer {
                if info != nil
                {
                    freeaddrinfo(info)
                }
            }
            let status: Int32 = getaddrinfo(host, String(port), nil, &info)
            guard status == 0 else {
                //print(errno, String(cString: gai_strerror(errno)))
                continue
            }
            var p = info
            var i = 0
            var ipFamily = ""
            //  var ipType = ""
            while p != nil {
                i += 1
                // use local copy of info
                let _info = p!.pointee
                p = _info.ai_next
                
                switch _info.ai_family {
                case PF_INET:
                    _info.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, { p in
                        inet_ntop(AF_INET, &p.pointee.sin_addr, &temp, socklen_t(temp.count))
                        ipFamily = "IPv4"
                    })
                case PF_INET6:
                    _info.ai_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1, { p in
                        inet_ntop(AF_INET6, &p.pointee.sin6_addr, &temp, socklen_t(temp.count))
                        ipFamily = "IPv6"
                    })
                default:
                    continue
                }
               // print(i,"\(ipFamily)\t\(String(cString: temp))", SocketType(rawValue: _info.ai_socktype)!)
                if ipFamily == "IPv4" {
                    return String(cString: temp)
                }
            }
        }
        return nil
    }
    
    public override init() {}
    
    public init(userLocation: CLLocationCoordinate2D?) {
        self.userLocation = userLocation
    }
    
    public init(address: HippoAddress?) {
        self.address = address
    }
    
    func toJSON() -> [String: Any]? {
        var params = [String: Any]()
        
        if let filledAddressInfo = address?.toJSON() {
            params["address"] = filledAddressInfo
        }
        
        if let location = self.userLocation {
            params["lat_long"] = "\(location.latitude),\(location.longitude)"
        }
        
        if let ipaddress = self.ipAddress {
            params["ip_address"] = ipaddress
        }
    
        if params.keys.count > 0 {
            return params
        }
        return nil
    }
}
