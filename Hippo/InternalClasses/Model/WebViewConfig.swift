//
//  WebViewConfig.swift
//  HippoChat
//
//  Created by Vishal on 05/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation

struct WebViewConfig {
    let initalUrl: URL
    let title: String
    var zoomingEnabled: Bool = false
    
    init(url: URL, title: String) {
        self.initalUrl = url
        self.title = title
    }
    
    init?(url: String, title: String) {
        guard !url.isEmpty, let parsedUrl = URL(string: url) else {
            return nil
        }
        self.init(url: parsedUrl, title: title)
    }
}
