//
//  HippoImageView.swift
//  HippoChat
//
//  Created by Vishal on 21/10/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit
//import Kingfisher

struct HippoResource {
    let url: URL
}
extension HippoResource: Resource {
    var cacheKey: String {
        return url.absoluteString
    }
    
    var downloadURL: URL {
        return url
    }
}

class HippoImageView: UIImageView {
    var resource: HippoResource?
    var imageURL: URL? {
        return resource?.downloadURL
    }
    var placeholder: UIImage?
}

extension HippoImageView {
    func setImage(resource: HippoResource?, placeholder: UIImage?) {
        self.resource = resource
        self.placeholder = placeholder
        
        self.kf.setImage(with: resource, placeholder: placeholder, options: nil, progressBlock: { (recievedSize, totalSize) in
            
        }) { (image, error, cacheType, url) in
            if url == self.imageURL, let im = image {
                self.image = im
            }
        }
    }
}
