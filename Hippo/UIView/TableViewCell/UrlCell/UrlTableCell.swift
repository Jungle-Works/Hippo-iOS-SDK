//
//  UrlTableCell.swift
//  Hippo
//
//  Created by Arohi Magotra on 08/03/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import UIKit

final
class UrlTableCell: UITableViewCell {

    //MARK:- IBOutlets
    @IBOutlet private var label_Url : UILabel!{
        didSet{
            label_Url.font = UIFont.regular(ofSize: 14.0)
        }
    }
    @IBOutlet private var buttonCross : UIButton!
    @IBOutlet private var activityIndicator : UIActivityIndicatorView!{
        didSet{
            activityIndicator.color = .black
            activityIndicator.isHidden = true
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    //MARK:- Clousers
    var crossBtnTapped: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- Functions
    
    func config(url: TicketUrl){
        activityIndicator.isHidden = url.isUploaded ?? true
        buttonCross.isHidden = !(url.isUploaded ?? true)
        if url.isUploaded ?? true{
            activityIndicator.stopAnimating()
        }else{
            activityIndicator.startAnimating()
        }
        label_Url.text = url.name ?? ""
    }
    
    
    @IBAction private func action_crossbtn(){
        self.crossBtnTapped?()
    }
    
}
