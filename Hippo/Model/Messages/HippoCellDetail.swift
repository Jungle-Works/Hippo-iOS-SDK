//
//  HippoCellDetail.swift
//  Fugu
//
//  Created by Vishal on 05/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation


class HippoCellDetail: NSObject {
    var showSenderName: Bool = true
    
    var senderNameHeight: CGFloat = 0
    var messageHeight: CGFloat = 0
    var footerHeight: CGFloat = 0
    var additionalContentHeight: CGFloat = 0
    var padding: CGFloat = 0
    
    var headerHeight: CGFloat = 0
    var actionHeight: CGFloat?
    var responseHeight: CGFloat = 0
    /// Customer button messages (type 20) keep their chips after a pick, with the answer
    /// bubble below them - both rows count towards the cell height.
    var stacksResponseUnderActions: Bool = false
    
    
    private var totalHeight: CGFloat? = nil
    
    var cellHeight: CGFloat {
        guard totalHeight == nil  else {
            return totalHeight!
        }
        let height = findTotalHeight()
        totalHeight = height
        
        print(height)
        return height 
    }
    
    private func findTotalHeight() -> CGFloat {
        var height: CGFloat = 0
        
        if showSenderName {
            height += senderNameHeight
        }
        height += messageHeight
        height += footerHeight
        height += additionalContentHeight
        height += padding
        height += headerHeight
        if stacksResponseUnderActions {
            height += (actionHeight ?? 0) + responseHeight
        } else {
            height += actionHeight ?? responseHeight
        }
        
        return height
    }
}
