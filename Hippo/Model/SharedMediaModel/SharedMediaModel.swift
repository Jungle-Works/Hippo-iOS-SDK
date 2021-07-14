//
//  SharedMediaModel.swift
//  HippoAgent
//
//  Created by Arohi Magotra on 18/03/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

struct ShareMediaModel: Decodable {
    let message_type: Int?
    let muid: String?
    let message: String?
    let file_name: String?
    let image_url: String?
    let thumbnail_url: String?
    let integration_source: Int?
    let document_type : String?
    let url : String?
}
