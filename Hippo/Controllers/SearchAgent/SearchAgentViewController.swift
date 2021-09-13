//
//  SearchAgentViewController.swift
//  Hippo
//
//  Created by Arohi Sharma on 14/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class SearchAgentViewController: UIViewController {

    //MARK:- IBOutlets
    
    
    
    
    //MARK:- UIViewController Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //MARK:- IBAction
    
    @IBAction func action_BackBtn(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Function
    
    class func getNewInstance() -> SearchAgentViewController {
       let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
       let vc = storyboard.instantiateViewController(withIdentifier: "SearchAgentViewController") as! SearchAgentViewController
       return vc
    }

}
