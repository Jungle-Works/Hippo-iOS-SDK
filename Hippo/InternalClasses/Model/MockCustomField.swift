//
//  MockCustomField.swift
//  HippoAgent
//
//  Created by Vishal on 19/11/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

struct MockCustomField {
    let defaultFields: [[String: Any]] = [[
        "field_name": "Enter User Name",
        "field_type": "Text",
        "display_name": "User Name",
        "is_required": true,
        "placeholder": "User Name",
        "id": "abcd",
        "show_to_customer": false,
        "can_agent_edit": false,
        "value": ""
        ], [
            "field_name": "Enter About yourself",
            "field_type": "TextArea",
            "display_name": "Bio",
            "is_required": true,
            "placeholder": "Enter About yourself",
            "id": "abcd",
            "show_to_customer": false,
            "can_agent_edit": false,
            "value": ""
        ], [
            "field_name": "Enter your age",
            "field_type": "Number",
            "display_name": "Age",
            "is_required": true,
            "placeholder": "Enter Age",
            "id": "abcd",
            "show_to_customer": false,
            "can_agent_edit": false,
            "value": ""
        ], [
            "field_name": "Enter Email",
            "field_type": "Email",
            "display_name": "Email",
            "is_required": true,
            "placeholder": "Enter Email",
            "id": "abcd",
            "show_to_customer": false,
            "can_agent_edit": false,
            "value": ""
        ], [
            "field_name": "Enter Contact Number",
            "field_type": "Telephone",
            "display_name": "Contact",
            "is_required": true,
            "placeholder": "Phone number",
            "id": "abcd",
            "show_to_customer": false,
            "can_agent_edit": false,
            "value": ""
        ], [
            "field_name": "Add your photo",
            "field_type": "Document",
            "display_name": "User Photo",
            "is_required": true,
            "placeholder": "Photo",
            "id": "abcd",
            "show_to_customer": true,
            "can_agent_edit": false,
            "value": ""
        ]]
}
