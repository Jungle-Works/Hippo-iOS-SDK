//
//  OfferPopUpVC.swift
//  Hippo
//
//  Created by soc-admin on 12/01/22.
//

import UIKit

class OfferPopUpVC: UIViewController {
    
    //MARK :- IB OUTLETS
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var viewHtCons: NSLayoutConstraint!
    
    // MARK: - Properties
    var currentPage = 0
    var popUpData: PromotionalPopUpData?
    var rawData: [String: Any]?
    var onButtonOneClick: (([String: Any]) -> Void)?
    var onButtonTwoClick: (([String: Any]) -> Void)?
    var btnOneCallbackData: [String: Any]?
    var btnTwoCallbackData: [String: Any]?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControll.numberOfPages = popUpData?.data?.count ?? 0
        pageControll.currentPageIndicatorTintColor = HippoConfig.shared.theme.themeColor//UIColor.hexStringToUIColor(hex: popUpData?.data?.first?.customAttributes?.buttons?.first?.backgroundColor ?? "")
        setUpCollView()
        
        pageControll.isHidden = popUpData?.data?.count ?? 0 == 1
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension OfferPopUpVC{
    func setUpCollView(){
        collView.delegate = self
        collView.dataSource = self
        collView.reloadData()
    }
}

extension OfferPopUpVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return popUpData?.data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferPopUpCVC", for: indexPath) as! OfferPopUpCVC
        cell.setUpCell(with: (popUpData?.data?[indexPath.section])!)
        cell.btnOne.tag = indexPath.section
        cell.btnTwo.tag = indexPath.section
        cell.btnOne.addTarget(self, action: #selector(btnOneTapped), for: .touchUpInside)
        cell.btnTwo.addTarget(self, action: #selector(btnTwoTapped), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return centerItemsInCollectionView(cellHeight: getCellHeight(at: section))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: getCellHeight(at: indexPath.section))//collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x / scrollView.frame.size.width).rounded())
        if page != currentPage{
            currentPage = page
            self.pageControll.currentPage = currentPage
//            self.pageControll.currentPageIndicatorTintColor = UIColor.hexStringToUIColor(hex: popUpData?.data?[currentPage].customAttributes?.buttons?.first?.backgroundColor ?? "")
        }
    }
    
    func centerItemsInCollectionView(cellHeight: Double) -> UIEdgeInsets {
        let topInset = (collView.frame.height - CGFloat(cellHeight)) / 2 - 20
        let bottomInset = topInset + 20
        return UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right:0)
    }
    
    func getCellHeight(at index : Int) -> CGFloat{
        let imgHt = popUpData?.data?[index].customAttributes?.image?.thumbnailURL?.isEmpty ?? true ? 0 : self.collView.frame.width - 56
        let titleHt = 18
        let descHt = min(popUpData?.data?[index].datumDescription?.height(constraintedWidth: view.frame.width - 36, font: UIFont.regular(ofSize: 16)) ?? 0, 80)
        let btnOneHt = popUpData?.data?[index].customAttributes?.buttons?.count ?? 0 == 0 ? 0 : 40
        let btnTwoHt = popUpData?.data?[index].customAttributes?.buttons?.count ?? 0 > 1 ? 40 : 0
        var space = 0
        space += imgHt > 0 ? 12 : 0
        space += btnOneHt > 0 ? 12 : 0
        space += btnTwoHt > 0 ? 12 : 0
        let height = Int(imgHt) + titleHt + Int(descHt) + btnOneHt + btnTwoHt + space + 24
        return CGFloat(height)
    }
    
}

extension OfferPopUpVC {
    func openUrl(with link: String){
        guard let url = URL(string: link), UIApplication.shared.canOpenURL(url) else {
          return
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func btnOneTapped(sender: UIButton){
        let btnData = popUpData?.data?[sender.tag].customAttributes?.buttons?.first
        
        if let url = btnData?.url, btnData?.actionType == 1{
            openUrl(with: url)
        }
        
//        if let btnSendData = btnData?.callbackData, btnData?.actionType == 2{
//            self.onButtonOneClick?(btnSendData)
//        }
        if let data = getDataToSendCallBackIfExists(for: sender.tag, for: 0){
            self.onButtonOneClick?(data)
        }
        
        HippoUserDetail.hitStatsAPi(pushContent: nil, linkClicked: btnData?.url, channelId: popUpData?.data![sender.tag].channelID, actionType: btnData?.actionType)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnTwoTapped(sender: UIButton){
        let btnData = popUpData?.data?[sender.tag].customAttributes?.buttons?.last
        if let url = btnData?.url{
            openUrl(with: url)
        }
        
//        if let btnSendData = btnData?.callbackData, btnData?.actionType == 2{
//            self.onButtonTwoClick?(btnSendData)
//        }
        if let data = getDataToSendCallBackIfExists(for: sender.tag, for: 1){
            self.onButtonTwoClick?(data)
        }
        
        HippoUserDetail.hitStatsAPi(pushContent: nil, linkClicked: btnData?.url, channelId: popUpData?.data![sender.tag].channelID, actionType: btnData?.actionType)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDataToSendCallBackIfExists(for buttonTag: Int, for buttonNumber: Int) -> [String: Any]? {
        guard let rawData = rawData else {return nil}
        guard let data = rawData["data"] as? [[String: Any]] else {return nil}
        guard data.indices.contains(buttonTag) else {return nil}
        guard let attr = data[buttonTag]["custom_attributes"] as? [String:Any] else {return nil}
        guard let buttonData = attr["buttons"] as? [[String: Any]] else {return nil}
        guard buttonData.indices.contains(buttonNumber) else {return nil}
        let selectedButton = buttonData[buttonNumber]
        guard let actionType = selectedButton["action_type"] as? Int, actionType == 2 else {return nil}
        guard let callBackData = selectedButton["callback_data"] as? [String: Any] else {return nil}
        return callBackData
        
//        ((((((rawData as! [String: Any])["data"] as! [[String: Any]]).first as! [String : Any])["custom_attributes"] as! [String: Any])["buttons"] as! [[String: Any]]).first!)["callback_data"]
    }
}

extension String {
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()

        return label.frame.height
     }
}
