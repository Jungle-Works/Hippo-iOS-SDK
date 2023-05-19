//
//  TextFieldsTableViewCell.swift
//  HippoAgent
//
//  Created by Neha Vaish on 21/04/23.
//  Copyright © 2023 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


class TextFieldsTableViewCell: UITableViewCell {


    @IBOutlet var textField: UITextField!
   
    var callBack : ((String)->())?
    var imageName = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.layer.cornerRadius = 6
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1).cgColor
        textField.setRightPaddingPoints(10)
        textField.tintColor = .darkGray
        textField.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func textField(_ sender: UITextField) {
        callBack?(textField.text ?? "")
    }
}


extension UITextField {

enum Direction {
    case Left
    case Right
}

// add image to textfield
func withImage(direction: Direction, image: UIImage, colorSeparator: UIColor, colorBorder: UIColor){
    let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
    mainView.layer.cornerRadius = 5

    let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
    view.backgroundColor = .white
    view.clipsToBounds = true
    view.layer.cornerRadius = 5
    view.layer.borderWidth = CGFloat(0.5)
    view.layer.borderColor = UIColor.clear.cgColor
    mainView.addSubview(view)

    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    imageView.frame = CGRect(x: 12.0, y: 10.0, width: 24.0, height: 24.0)
    view.addSubview(imageView)

    let seperatorView = UIView()
    seperatorView.backgroundColor = colorSeparator
    mainView.addSubview(seperatorView)

    if(Direction.Left == direction){ // image left
        seperatorView.frame = CGRect(x: 45, y: 0, width: 5, height: 45)
        self.leftViewMode = .always
        self.leftView = mainView
    } else { // image right
        seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 45)
        self.rightViewMode = .always
        self.rightView = mainView
    }
    mainView.isUserInteractionEnabled = false
    self.layer.borderColor = colorBorder.cgColor
    self.layer.borderWidth = CGFloat(1.0)
    self.layer.cornerRadius = 5
    
}

}
