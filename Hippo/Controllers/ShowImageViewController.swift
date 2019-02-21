//
//  ShowImageViewController.swift
//  ChitChapp
//
//  Created by Click Labs 65 on 7/23/15.
//  Copyright (c) 2015 click Labs. All rights reserved.
//

import UIKit

class ShowImageViewController: UIViewController , UIScrollViewDelegate {
    @IBOutlet weak var imageView: So_UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var crossButton: UIButton!
    var imageToShow: UIImage?
    var imageURLString = ""
    var localImagePath: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crossButton.layer.cornerRadius = 5//31.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if imageToShow != nil {
            self.imageView.image = imageToShow
        } else if imageURLString.isEmpty == false,
            let url = URL(string: imageURLString) {
            let placeHolderImage = HippoConfig.shared.theme.placeHolderImage
            imageView.kf.setImage(with: url, placeholder: placeHolderImage)
        } else if let localPath = localImagePath, doesFileExistsAt(filePath: localPath) {
            self.imageView.image = UIImage(contentsOfFile: localPath)
        }
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5
        scrollView.flashScrollIndicators()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return self.imageView
   }
    func doesFileExistsAt(filePath: String) -> Bool {
        return (try? Data(contentsOf: URL(fileURLWithPath: filePath))) != nil
    }
    
    
    @IBAction func crossButtonTapped(_ sender :AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
   
   // MARK: - Type Methods
   class func getFor(imageUrlString: String) -> ShowImageViewController {
      let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
      let vc = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
      vc.imageURLString = imageUrlString
      return vc
   }
    class func getFor(localPath: String) -> ShowImageViewController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        vc.localImagePath = localPath
        return vc
    }
}
