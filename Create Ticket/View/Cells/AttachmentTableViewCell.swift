//
//  AttachmentTableViewCell.swift
//  HippoAgent
//
//  Created by Neha Vaish on 21/04/23.
//  Copyright © 2023 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

class AttachmentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionViewTopConst: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addAttachmentBtn: UIButton!
    
    var imageCallBack: ((String?)->())?
    var videoCallBack: ((String?, String?)->())?
    var callBack: ((String)->())?
    var attachments = [AttachmentData]()
    var deleteCallBack: ((Int)->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func reload(){
       
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle:  Bundle(for: ImageCollectionViewCell.self)), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.register(UINib(nibName: "UploadCollectionViewCell", bundle:  Bundle(for: UploadCollectionViewCell.self)), forCellWithReuseIdentifier: "UploadCollectionViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    @IBAction func attachBtnPressed(_ sender: UIButton) {
        callBack?("")
    }
    
   
}

extension AttachmentTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        
        if indexPath.item == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadCollectionViewCell", for: indexPath) as! UploadCollectionViewCell
            
           
//            if #available(iOS 13.0, *) {
//                let dashedBorderLayer = cell.dashedView.addLineDashedStroke(pattern: [2, 5], radius: 6, color: UIColor.placeholderText.cgColor)
//                cell.dashedView.layer.addSublayer(dashedBorderLayer)
//            } else {
//                // Fallback on earlier versions
//            }
            if #available(iOS 13.0, *) {
                cell.dashedView.layer.borderColor = UIColor.placeholderText.cgColor
            } else {
                // Fallback on earlier versions
            }
            cell.dashedView.layer.borderWidth = 1
            cell.dashedView.layer.cornerRadius = 6
           
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
            cell.thumbnailmage.kf.indicatorType = .activity
            cell.thumbnailmage.tintColor = .black
            if attachments[indexPath.row - 1].type == "application/pdf"{
                cell.thumbnailmage.image = HippoConfig.shared.theme.pdfIcon
            }else if attachments[indexPath.row - 1].type == "application/vnd.ms-excel"{
                cell.thumbnailmage.image = HippoConfig.shared.theme.excelIcon
            }else if attachments[indexPath.row - 1].type == "application/msword"{
                cell.thumbnailmage.image = HippoConfig.shared.theme.docIcon
            }else if attachments[indexPath.row - 1].type ==  "text/csv"{
                cell.thumbnailmage.image = HippoConfig.shared.theme.csvIcon
            }else if attachments[indexPath.row - 1].type ==  "application/vnd.ms-powerpoint"{
                cell.thumbnailmage.image = HippoConfig.shared.theme.pptIcon
            }else if attachments[indexPath.row - 1].type ==  "text/plain"{
                cell.thumbnailmage.image = HippoConfig.shared.theme.txtIcon
            }else if attachments[indexPath.row - 1].type ==  "video/mp4" || attachments[indexPath.row - 1].type == "video/quicktime" || attachments[indexPath.row - 1].type == "video/3gpp"{
                cell.thumbnailmage.image = UIImage(named: "video", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            }else{
                cell.thumbnailmage.contentMode = .scaleAspectFill
                cell.thumbnailmage.kf.setImage(with: URL(string: attachments[indexPath.row - 1].path))
                
            }
            cell.deleteCallBack = { item in
                self.deleteCallBack?(indexPath.item - 1)
            }
//            cell.dashedView.layer.borderWidth = 1
//            cell.dashedView.layer.cornerRadius = 6
//            if #available(iOS 13.0, *) {
//                cell.dashedView.layer.borderColor = UIColor.placeholderText.cgColor
//            } else {
//                // Fallback on earlier versions
//            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0{
            callBack?("")
        }else{
            if attachments[indexPath.row - 1].type ==  "video/mp4" || attachments[indexPath.row - 1].type == "video/quicktime" || attachments[indexPath.row - 1].type == "video/3gpp"{
                videoCallBack?("\(attachments[indexPath.row - 1].path)","\(attachments[indexPath.row - 1].name)")
            }else if attachments[indexPath.row - 1].type ==  "application/pdf" || attachments[indexPath.row - 1].type == "application/vnd.ms-excel" || attachments[indexPath.row - 1].type == "text/csv" || attachments[indexPath.row - 1].type == "application/vnd.ms-powerpoint" || attachments[indexPath.row - 1].type ==  "text/plain"{
               
            }else{
                imageCallBack?("\(attachments[indexPath.row - 1].path)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/3.0
        let yourHeight = 100.0

        return CGSize(width: yourWidth, height: yourHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
        
    }
    
   
}


extension UIView {
    @discardableResult
    func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, color: CGColor) -> CALayer {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = color
        borderLayer.lineDashPattern = pattern
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.addSublayer(borderLayer)
        return borderLayer
    }
}
