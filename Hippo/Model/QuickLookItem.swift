//
//  QuickLookItem.swift
//  Hippo
//
//  Created by Vishal on 16/01/19.
//

import Foundation
import QuickLook

class QuickLookItem: NSObject, QLPreviewItem {
    let previewItemURL: URL?
    let previewItemTitle: String?
    
    init(previewItemURL: URL?, previewItemTitle: String?) {
        self.previewItemTitle = previewItemTitle
        self.previewItemURL = previewItemURL
    }
    
}
