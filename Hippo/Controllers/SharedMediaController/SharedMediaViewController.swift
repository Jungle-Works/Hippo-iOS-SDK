//
//  SharedMediaViewController.swift
//  HippoAgent
//
//  Created by sreshta bhagat on 15/03/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import QuickLook

final
class SharedMediaViewController: UIViewController {
    
    
    @IBOutlet private var viewNavigationBar : NavigationBar!
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "SharedMediaCell", bundle: FuguFlowManager.bundle), forCellWithReuseIdentifier: "SharedMediaCell")
        }
    }
    
   //MARK:- Variables
    
    
   private var mediaArr = [ShareMediaModel]()
    
   var channelId : Int?
   var downloadingDoc = [String:String]()
   var qldataSource: HippoQLDataSource?
    
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
        addNotificationObservers()
        
    }
    
    func addNotificationObservers() {
       NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadCompleted(_:)), name: Notification.Name.fileDownloadCompleted, object: nil)
    }
    
    @objc func fileDownloadCompleted(_ notification: Notification) {
       guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String else {
          return
       }
       openFile(url: url, name: downloadingDoc[url] ?? "")
       
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
        viewNavigationBar.title = HippoStrings.sharedMediaTitle
        viewNavigationBar.leftButton.addTarget(self, action: #selector(backBtn), for: .touchUpInside)
    }
    

    //MARK:- Private Functions

    private func getMediaData(){
      
        guard let channelId = channelId else {
            return
        }
        
        
        var params: [String : Any] = ["channel_id" : channelId]
        if currentUserType() == .agent {
            params["access_token"] = HippoConfig.shared.agentDetail?.fuguToken
        }else {
            params["app_secret_key"] = HippoConfig.shared.appSecretKey
        }
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.SharedMedia.rawValue) { (response, error, _, statusCode) in
            guard error == nil,
                  let response = response as? [String: Any],
                  let data = response["data"] as? Array<Any> else {
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
        cell.imageViewMedia.tintColor = nil
        switch mediaArr[indexPath.row].document_type {
            case FileType.image.rawValue:
                cell.imageViewMedia.kf.setImage(with: URL(string: mediaArr[indexPath.row].image_url ?? mediaArr[indexPath.row].url ?? ""))
            case FileType.video.rawValue:
                cell.imageViewMedia.kf.setImage(with: URL(string: mediaArr[indexPath.row].thumbnail_url ?? ""))
                cell.buttonPlay.isHidden = false
            case FileType.audio.rawValue:
                cell.imageViewMedia.tintColor = .black
                cell.imageViewMedia.contentMode = .scaleAspectFit
                cell.imageViewMedia.image = HippoConfig.shared.theme.defaultDocIcon
                
            case FileType.document.rawValue:
                cell.imageViewMedia.tintColor = .black
                cell.imageViewMedia.image = HippoConfig.shared.theme.defaultDocIcon
            
        default:
            cell.imageViewMedia.kf.setImage(with: URL(string: mediaArr[indexPath.row].image_url ?? mediaArr[indexPath.row].url ?? ""))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mediaArr[indexPath.row].document_type == nil || mediaArr[indexPath.row].document_type == FileType.image.rawValue{
            var showImageVC: ShowImageViewController?
            if let originalUrl = mediaArr[indexPath.row].image_url ?? mediaArr[indexPath.row].url, originalUrl.count > 0 {
                showImageVC = ShowImageViewController.getFor(imageUrlString: originalUrl)
            }
            
            guard showImageVC != nil else {
                return
            }
            
            self.modalPresentationStyle = .overFullScreen
            self.present(showImageVC!, animated: true, completion: nil)
        }else {
           
            guard let url = mediaArr[indexPath.row].url else {
                showAlert(title: "", message: HippoStrings.somethingWentWrong, actionComplete: nil)
                return
            }
            guard DownloadManager.shared.isFileDownloadedWith(url: url) else {
                DownloadManager.shared.downloadFileWith(url: url, name: mediaArr[indexPath.row].file_name ?? "")
                downloadingDoc[url] = mediaArr[indexPath.row].file_name ?? ""
                return
            }
            
            openFile(url: url, name: mediaArr[indexPath.row].file_name ?? "")
        }
    }

    func openFile(url: String, name: String) {
        guard  DownloadManager.shared.isFileDownloadedWith(url: url) else {
            print("-------\nERROR\nFile is not downloaded\n--------")
            return
        }
        var fileName = name
        if fileName.count > 10 {
            let stringIndex = fileName.index(fileName.startIndex, offsetBy: 9)
            fileName = String(fileName[..<stringIndex])
        }
        openQuicklookFor(fileURL: url, fileName: fileName)
    }
    
    func openQuicklookFor(fileURL: String, fileName: String) {
        guard let localPath = DownloadManager.shared.getLocalPathOf(url: fileURL) else {
            return
        }
        let url = URL(fileURLWithPath: localPath)
        
        let qlItem = QuickLookItem(previewItemURL: url, previewItemTitle: fileName)
        
        let qlPreview = QLPreviewController()
        self.qldataSource = HippoQLDataSource(previewItems: [qlItem])
        qlPreview.delegate = self.qldataSource
        qlPreview.dataSource = self.qldataSource
        qlPreview.title = fileName
        //        qlPreview.setupCustomThemeOnNavigationBar(hideNavigationBar: false)
        qlPreview.navigationItem.hidesBackButton = false
        qlPreview.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(qlPreview, animated: true)
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


