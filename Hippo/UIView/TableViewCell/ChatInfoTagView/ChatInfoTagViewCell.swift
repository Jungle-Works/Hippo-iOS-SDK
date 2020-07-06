//
//  ChatInfoTagViewCell.swift
//  Fugu
//
//  Created by clickpass on 10/11/17.
//  Copyright © 2017 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


class ChatInfoTagViewCell: UITableViewCell {

    var tagDetailArray = [TagDetail]()
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var tagTextLabel: UILabel!    
    @IBOutlet weak var tagViewOutlet: TagListView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagTextLabel.text = HippoStrings.tags
        tagTextLabel.font = UIFont.regular(ofSize: 15)
        tagViewOutlet.textFont = UIFont.regular(ofSize: 15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCellData(tagsArray: [TagDetail]) {
        tagDetailArray = tagsArray
        tagDetailArray.sort { $0.tagName?.lowercased() ?? "" < $1.tagName?.lowercased() ?? ""}
        
        tagViewOutlet.removeAllTags()
        _ = tagViewOutlet.addTags(tagDetailArray)
        self.layoutIfNeeded()
        
    }
    
    
}


