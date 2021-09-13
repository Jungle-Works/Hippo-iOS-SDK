//
//  UIImageView+Extension.swift
//  Hippo
//
//  Created by Vishal on 31/07/19.
//

import UIKit




extension UIImageView {
    
    func displayImage(imageString: String, placeHolderImage: UIImage?) {
        guard let imageURL = URL(string: imageString), !imageString.isEmpty else {
            self.image = placeHolderImage
//            self.clipsToBounds = true
            return
        }
        self.kf.setImage(with: imageURL, placeholder: placeHolderImage, completionHandler: {(image, error, _, _) in
            self.clipsToBounds = true
            self.clipsToBounds = true
            self.layer.masksToBounds = true
        })
    }
    func setStatusImageView(status: String) {
        
        switch status {
        case AgentStatus.available.rawValue:
            self.backgroundColor = UIColor.availableStatusColor
            self.image = nil
            self.contentMode = .center
            
        case AgentStatus.offline.rawValue:
            self.backgroundColor = UIColor.offlineStatusColor
            self.image = nil
            self.contentMode = .center
            
        case AgentStatus.away.rawValue:
            self.backgroundColor = UIColor.awayStatusColor
            self.image = HippoConfig.shared.theme.awayStatusIcon
            self.contentMode = .center
            
        default:
            self.backgroundColor = UIColor.awayStatusColor
            self.image = nil
            self.contentMode = .center
        }
    }
    
    func setTextInImage(string: String?,
                       color: UIColor? = nil,
                       circular: Bool = false,
                       textAttributes: [NSAttributedString.Key: Any]? = nil) {
        
        let image = imageSnap(text: string != nil ? string?.trimWhiteSpacesAndNewLine().initials : "",
                              color: color ?? .random,
                              circular: circular,
                              textAttributes:textAttributes)
        
        if let newImage = image {
            self.image = newImage
        }
    }
    
    private func imageSnap(text: String?,
                           color: UIColor,
                           circular: Bool,
                           textAttributes: [NSAttributedString.Key: Any]?) -> UIImage? {
        
        let scale = Float(UIScreen.main.scale)
        var size = bounds.size
        if contentMode == .scaleToFill || contentMode == .scaleAspectFill || contentMode == .scaleAspectFit || contentMode == .redraw {
            size.width = CGFloat(floorf((Float(size.width) * scale) / scale))
            size.height = CGFloat(floorf((Float(size.height) * scale) / scale))
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        let context = UIGraphicsGetCurrentContext()
        if circular {
            let path = CGPath(ellipseIn: bounds, transform: nil)
            context?.addPath(path)
            context?.clip()
        }
        
        // Fill
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Text
        if let text = text {
            let attributes = textAttributes ?? [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font: UIFont.regular(ofSize: 20.0)]
            
            let textSize = text.size(withAttributes: attributes)
            let bounds = self.bounds
            let rect = CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height)
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: UIColor Helper

extension UIColor {
    
    /// Returns random generated color.
    static var random: UIColor {
        srandom(arc4random())
        var red: Double = 0
        
        while (red < 0.1 || red > 0.84) {
            red = drand48()
        }
        
        var green: Double = 0
        while (green < 0.1 || green > 0.84) {
            green = drand48()
        }
        
        var blue: Double = 0
        while (blue < 0.1 || blue > 0.84) {
            blue = drand48()
        }
        
        return .init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    
    static func colorHash(name: String?) -> UIColor {
        guard let name = name else {
            return .red
        }
        
        var nameValue = 0
        for character in name {
            let characterString = String(character)
            let scalars = characterString.unicodeScalars
            nameValue += Int(scalars[scalars.startIndex].value)
        }
        
        var r = Float((nameValue * 123) % 51) / 51
        var g = Float((nameValue * 321) % 73) / 73
        var b = Float((nameValue * 213) % 91) / 91
        
        let defaultValue: Float = 0.84
        r = min(max(r, 0.1), defaultValue)
        g = min(max(g, 0.1), defaultValue)
        b = min(max(b, 0.1), defaultValue)
        
        return .init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
    }
    
    func hippoToHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}

// MARK: String Helper

extension String {
    
    public var initials: String {
        var finalString = String()
        var words = components(separatedBy: .whitespacesAndNewlines)
        
        if let firstCharacter = words.first?.first {
            finalString.append(String(firstCharacter))
            words.removeFirst()
        }
        
        //        if let lastCharacter = words.last?.first {
        //            finalString.append(String(lastCharacter))
        //        }
        
        return finalString.uppercased()
    }
    func hippoHtmlAttributedString(font: UIFont, color: UIColor, alignment: NSTextAlignment) -> NSMutableAttributedString? {
        let htmlTemplate = """
            <!doctype html>
            <html>
              <head>
                <style>
                  body {
                    color: \(color.hippoToHexString());
                    font-family: \(font.fontName);
                    font-size: \(font.pointSize)px;
                  }
                </style>
              </head>
              <body>
                \(self)
              </body>
            </html>
            """
        
        guard let data = htmlTemplate.data(using: .utf8) else {
            return nil
        }
        
        guard let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        ) else {
            return nil
        }
        
        let alignmentStyle = NSMutableParagraphStyle()
        alignmentStyle.alignment = alignment
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: alignmentStyle, range: NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
    
    var containsHtmlTags: Bool {
        return self.contains("<") && self.contains(">")
    }
}
