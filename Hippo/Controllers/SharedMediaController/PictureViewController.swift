//
//  PictureViewController.swift
//  HippoAgent
//
//  Created by sreshta bhagat on 18/03/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController
{
    @IBOutlet weak var fullImag: UIImageView!
    
    
    var image = UIImage()
    
    
    
    var imageUrl = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        fullImag.image = image
        fullImag.kf.setImage(with: URL(string: imageUrl))
        
    }
    
    
    
    
}
