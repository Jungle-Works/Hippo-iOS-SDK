//
//  Socomo+Customs.swift
//  Fugu
//
//  Created by Gagandeep Arora on 08/09/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
class So_UIView: UIView {
    
}

//@IBDesignable
class So_CustomLabel: UILabel {
    
}

//@IBDesignable
class So_TableViewCell: UITableViewCell {
    
}

//@IBDesignable
class So_UIImageView: UIImageView {
   
   
    @IBInspectable
    var ImageColor: UIColor {
        set {
            self.image = self.image?.withRenderingMode(.alwaysTemplate)
            self.tintColor = newValue
            //self.font = UIFont.boldProximaNova(withSize: newValue)
        }
        get {
            return .clear
        }
    }
    
}
