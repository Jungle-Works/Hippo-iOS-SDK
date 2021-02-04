//
//  HippoQLDataSource.swift
//  Fugu
//
//  Created by Vishal on 14/01/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation
import QuickLook

class HippoQLDataSource: NSObject, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    let previewItems: [QLPreviewItem]
    
    init(previewItems: [QLPreviewItem]) {
        self.previewItems = previewItems
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewItems.count
    }
    
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItems[index]
    }
    
    func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
        return true
    }
    
}
