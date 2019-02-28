//
//  EmptyViewPlaceholderViewController.swift
//  SDKDemo1
//
//  Created by cl-macmini-67 on 05/02/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class EmptyViewPlaceholderViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var descLb: UILabel!
    @IBOutlet weak var image: UIImageView!
    var itemInfo = IndicatorInfo(title: "View")
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        self.descLb.textColor = HippoConfig.shared.theme.EmptyViewLabelTextColor
        self.descLb.font = HippoConfig.shared.theme.EmptyViewLabelTextFont
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
