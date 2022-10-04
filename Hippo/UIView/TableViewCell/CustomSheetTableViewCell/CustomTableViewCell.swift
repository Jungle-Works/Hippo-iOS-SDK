//
//  CustomTableViewCell.swift
//  SlideUpAnimation
//
//  Created by SHUBHAM AGARWAL on 26/02/19.
//  Copyright © 2019 SHUBHAM AGARWAL. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        view.backgroundColor = .white
        return view
    }()
    
    lazy var settingImage: UIImageView = {
        //       let imageView = UIImageView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        //        let imageView = UIImageView(frame: CGRect(x: 13, y: 15, width: 25, height: 25))
        let imageView = UIImageView(frame: CGRect(x: 13, y: 13, width: 25, height: 25))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var lbl: UILabel = {
        let lbl = UILabel(frame: CGRect(x: 60, y: 10, width: self.frame.width - 80, height: 30))
        lbl.textColor = .black
        return lbl
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        contentView.backgroundColor = .white
        contentView.addSubview(backView)
        backView.addSubview(settingImage)
        backView.addSubview(lbl)
    }
    
}
