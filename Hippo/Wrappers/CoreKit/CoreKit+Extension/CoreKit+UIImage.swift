//
//  CoreKit+UIImage.swift
//  Fugu
//
//  Created by Vishal on 09/01/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


public extension UIImage {
    func rotateCameraImageToProperOrientation(maxResolution: CGFloat) -> UIImage {
        let imgRef = self.cgImage
        
        let width = CGFloat(imgRef!.width)
        let height = CGFloat(imgRef!.height)
        
        var bounds = CGRect.init(x: 0, y: 0, width: width, height: height)
        var scaleRatio: CGFloat = 1
        
        if width > maxResolution || height > maxResolution {
            
            scaleRatio = min(maxResolution / bounds.size.width, maxResolution / bounds.size.height)
            bounds.size.height *= scaleRatio
            bounds.size.width *= scaleRatio
        }
        
        var transform = CGAffineTransform.identity
        let orient = self.imageOrientation
        let imageSize = CGSize(width: imgRef!.width, height: imgRef!.height)
        
        switch self.imageOrientation {
            
        case .up :
            transform = CGAffineTransform.identity
            
        case .upMirrored :
            
            transform = CGAffineTransform(translationX: imageSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            
        case .down :
            
            transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .downMirrored :
            
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
            
        case .left :
            
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = storedHeight
            
            transform = transform.rotated(by: 3.0 * CGFloat(Double.pi) / 2.0)
            
            
        case .leftMirrored :
            
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = storedHeight;
            transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: 3.0 * CGFloat(Double.pi) / 2.0)
            
        case .right :
            
            let storedHeight = bounds.size.height
            
            bounds.size.height = bounds.size.width
            bounds.size.width = storedHeight
            transform = CGAffineTransform(translationX: imageSize.height, y: 0.0)
            transform = transform.rotated(by: CGFloat(Double.pi) / 2.0)
            
        case .rightMirrored :
            
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = storedHeight
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(Double.pi) / 2.0)
            
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        
        
        if orient == .right || orient == .left {
            
            context!.scaleBy(x: -scaleRatio, y: scaleRatio)
            context!.translateBy(x: -height, y: 0)
            
        } else {
            
            context!.scaleBy(x: scaleRatio, y: -scaleRatio)
            context!.translateBy(x: 0, y: -height)
            
        }
        
        context?.concatenate(transform)
        
        context?.draw(imgRef!, in: CGRect.init(x: 0, y: 0, width: width, height: height))
        
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageCopy!
    }
    
}
