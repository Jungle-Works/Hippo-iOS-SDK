//
//  OfferPopUpCVC.swift
//  Hippo
//
//  Created by soc-admin on 12/01/22.
//

import UIKit

class OfferPopUpCVC: UICollectionViewCell {

    //MARK :- IB OUTLETS
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnOne: UIButton!
    @IBOutlet weak var btnTwo: UIButton!
    
    
    func setUpCell(with data: Datum){

        if let thumbnailUrl = data.customAttributes?.image?.thumbnailURL, thumbnailUrl.isEmpty == false, let url = URL(string: thumbnailUrl) {
            let placeHolderImage = HippoConfig.shared.theme.placeHolderImage
            
            imgView.kf.setImage(with: url, placeholder: placeHolderImage, completionHandler: { [weak self]  (_, error, _, _) in
            })
        }else{
            imgView.isHidden = true
        }
        
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 8
        imgView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        lblTitle.text = data.title
        lblDesc.text = data.datumDescription
        self.layer.cornerRadius = 8
        
        if let buttons = data.customAttributes?.buttons{
            if buttons.count > 1{
                btnOne.isHidden = false
                btnTwo.isHidden = false
                setUpBtn(btn: btnOne, data: data.customAttributes?.buttons?.first)
                setUpBtn(btn: btnTwo, data: data.customAttributes?.buttons?.last)
            }else{
                btnOne.isHidden = false
                btnTwo.isHidden = true
                setUpBtn(btn: btnOne, data: data.customAttributes?.buttons?.first)
            }
        }else{
            btnOne.isHidden = true
            btnTwo.isHidden = true
        }
    }
    
    func setUpBtn(btn: UIButton, data: ButtonPopUP?){
        btn.setTitle(data?.label, for: .normal)
        btn.setTitleColor(UIColor.hexStringToUIColor(hex: data?.textColor ?? ""), for: .normal)
        btn.backgroundColor = UIColor.hexStringToUIColor(hex: data?.backgroundColor ?? "")
//        btn.isUserInteractionEnabled = data?.actionType == 1 ? true : false
    }
    
}
