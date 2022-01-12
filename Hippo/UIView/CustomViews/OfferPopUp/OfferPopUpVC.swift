//
//  OfferPopUpVC.swift
//  Hippo
//
//  Created by soc-admin on 12/01/22.
//

import UIKit

class OfferPopUpVC: UIViewController {
    
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var pageControll: UIPageControl!
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollView()
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferPopUpCVC", for: indexPath) as! OfferPopUpCVC
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
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
        }
    }
    
}
