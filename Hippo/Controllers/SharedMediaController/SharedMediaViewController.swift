//
//  SharedMediaViewController.swift
//  HippoAgent
//
//  Created by sreshta bhagat on 15/03/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import AXPhotoViewer
final
class SharedMediaViewController: UIViewController {
    
    
    @IBOutlet weak var backBtnClick: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "SharedMediaCell", bundle: nil), forCellWithReuseIdentifier: "SharedMediaCell")
        }
    }
    
   //MARK:- Variables
    
    
   private var mediaArr = [ShareMediaModel]()
    
   var channelId : Int?
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        collectionView
            .setCollectionViewLayout(layout, animated: true)
        getMediaData()
        setupNavigationBar()
        self.collectionView.reloadData()
       
        
    }
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupNavigationBar() {
        titleOfNavigationItem(barTitle: "Shared Media")
        setupCustomThemeOnNavigationBar(hideNavigationBar: false)
    }
    

    //MARK:- Private Functions

    private func getMediaData(){
        guard let accessToken = PersonInfo.getAccessToken() else {
            return
        }
        
        guard let channelId = channelId else {
            return
        }
        
        
        let params: [String : Any] = ["access_token": accessToken,
                                      "channel_id" : channelId]
        
        HTTPRequest(path: EndPoints.SharedMedia, parameters: params)
            .config(isIndicatorEnable: true, isAlertEnable: true)
            .handler { (response) in
                
                guard response.isSuccess,
                      let value = response.value as? [String: Any],
                      let data = value["data"] as? Array<Any> else {
                    
                    return
                }
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else{ return }
                
                let jsonDecoder = JSONDecoder()
                let decodedData = try? jsonDecoder.decode([ShareMediaModel].self, from: jsonData)
                
                self.mediaArr = decodedData ?? [ShareMediaModel]()
                
                self.collectionView.reloadData()
            }
        
    }
}
extension SharedMediaViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SharedMediaCell", for: indexPath) as! SharedMediaCell
        cell.buttonPlay.isHidden = true
        switch mediaArr[indexPath.row].document_type {
            case FileType.image.rawValue:
                cell.imageViewMedia.kf.setImage(with: URL(string: mediaArr[indexPath.row].image_url ?? mediaArr[indexPath.row].url ?? ""))
            case FileType.video.rawValue:
                cell.imageViewMedia.kf.setImage(with: URL(string: mediaArr[indexPath.row].thumbnail_url ?? ""))
                cell.buttonPlay.isHidden = false
            case FileType.audio.rawValue:
                cell.imageViewMedia.contentMode = .scaleAspectFit
                cell.imageViewMedia.image = UIImage(named: "defaultDoc")
                
            case FileType.document.rawValue:
                cell.imageViewMedia.image = UIImage(named: "defaultDoc")
            
        default:
            cell.imageViewMedia.kf.setImage(with: URL(string: mediaArr[indexPath.row].image_url ?? mediaArr[indexPath.row].url ?? ""))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mediaArr[indexPath.row].document_type == nil || mediaArr[indexPath.row].document_type == FileType.image.rawValue{
            let d  = AXPhoto(attributedTitle: nil, attributedDescription: nil, attributedCredit: nil, imageData: nil, image: nil, url: URL(string: mediaArr[indexPath.row].image_url ?? mediaArr[indexPath.row].url ?? ""))
            //let dataSource = AXPhotosDataSource(photos: [d])
            var transitionInfo: AXTransitionInfo?
            let pagingConfig = AXPagingConfig(navigationOrientation: .horizontal, interPhotoSpacing: 10)
            let datasource = AXPhotosDataSource(photos: [d], initialPhotoIndex: 0, prefetchBehavior: .aggressive)
            let photosViewController = AXPhotosViewController(dataSource: datasource, pagingConfig: pagingConfig, transitionInfo: transitionInfo)
            self.present(photosViewController, animated: true)
        }else {
            
            guard let appNavigationCtrlr = appNavigationController else {
                return
            }
            guard let url = mediaArr[indexPath.row].url else {
                showAlert(title: "", message: HippoStrings.someThingWentWrong, actionComplete: nil)
                return
            }
            guard let config = WebViewConfig(url: url, title: mediaArr[indexPath.row].file_name ?? "") else { return  }
            let vc = MediaWebViewController.getNewInstance(config: config)
            let navVC = UINavigationController(rootViewController: vc)
            navVC.setupCustomThemeOnNavigationController(hideNavigationBar: false)
            appNavigationCtrlr.present(navVC, animated: true, completion: nil)
        }
    }

}


extension SharedMediaViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = self.view.frame.size.width - 8
        return CGSize(width: ((collectionWidth/3) - 5), height: ((collectionWidth/3) - 5))
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return  UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}


