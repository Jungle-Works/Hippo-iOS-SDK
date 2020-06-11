//
//  MentionDataManager.swift
//  HippoAgent
//
//  Created by Vishal on 04/06/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

class MentionDataManager: NSObject {
    private let mentions: [Agent]
    var filteredMentions: [Agent] = []
    
    
    init(mentions: [Agent]) {
        self.mentions = mentions
        filteredMentions = mentions
    }
    
    @discardableResult
    func filterMentions(with mentionString: String) -> [Agent] {
        guard !mentionString.isEmpty else {
            filteredMentions = mentions
            return filteredMentions
        }
        let temp: [Agent] = mentions.filter { $0.name.lowercased().contains(mentionString.lowercased()) }
        filteredMentions = temp
        return filteredMentions
    }
}
