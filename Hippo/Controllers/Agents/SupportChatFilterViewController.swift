//
//  SupportChatFilterViewController.swift
//  Hippo
//
//  Created by Arohi Sharma on 17/12/20.
//  Copyright © 2020 CL-macmini-88. All rights reserved.
//

import UIKit

class SupportChatFilterViewController: UIViewController {

    //MARK:- Variables
    var supportFilterArr = [SupportFilter]()
    var filterApplied : (()->())?
    
    
    //MARK:- IBOutlets
    @IBOutlet weak var applyButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var applyButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultTableview: UITableView!{
        didSet{
           resultTableview.register(UINib(nibName: "FilterTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "FilterTableViewCell")
           resultTableview.register(UINib(nibName: "FilterOptionTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "FilterOptionTableViewCell")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if HippoConfig.shared.supportChatFilter == nil{
            supportFilterArr = getInitialFilter()
        }else{
            supportFilterArr = HippoConfig.shared.supportChatFilter ?? [SupportFilter]()
        }
        resultTableview.reloadData()
    }

    
    func getInitialFilter()->[SupportFilter]{
        var initialFilter = [SupportFilter]()
        initialFilter.append(SupportFilter(type: .status, value: [SupportFilterValues(value: HippoStrings.openChat, isSelected: false), SupportFilterValues(value: HippoStrings.closedChat, isSelected: false)]))
        initialFilter.append(SupportFilter(type: .type, value: [SupportFilterValues(value: HippoStrings.myChatsOnly, isSelected: false), SupportFilterValues(value: HippoStrings.unassignedChats, isSelected: false), SupportFilterValues(value: HippoStrings.mySupportChats, isSelected: false)]))
        return initialFilter
    }
    
}
extension SupportChatFilterViewController{
    
    @IBAction func button_ApplyFilter(){
        HippoConfig.shared.supportChatFilter = self.supportFilterArr
        self.filterApplied?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func button_ResetFilter(){
        HippoConfig.shared.supportChatFilter = nil
        self.supportFilterArr.removeAll()
        self.supportFilterArr = getInitialFilter()
        self.resultTableview.reloadData()
        self.filterApplied?()
         //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func button_Dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension SupportChatFilterViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return supportFilterArr.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportFilterArr[section].value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell", for: indexPath) as? FilterTableViewCell else {
            return UITableViewCell()
        }
        cell.filterLabel.text = supportFilterArr[indexPath.section].value?[indexPath.row].value
        cell.heightWidthOfImage.constant = 30
        cell.tickImageView.tintColor = .black
        cell.tickImageView?.image = supportFilterArr[indexPath.section].value?[indexPath.row].isSelected ?? false ? HippoConfig.shared.theme.checkBoxActive : HippoConfig.shared.theme.checkBoxInActive
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "FilterOptionTableViewCell") as? FilterOptionTableViewCell
        headerView?.cellLabel.text = supportFilterArr[section].type.getHeaderValue()
        return headerView ?? UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight = 50
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 50
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (supportFilterArr[indexPath.section].type == .type){
            let values = supportFilterArr[indexPath.section].value ?? [SupportFilterValues]()
            for (ind, _) in values.enumerated(){
                if ind == indexPath.row{
                   supportFilterArr[indexPath.section].value?[indexPath.row].isSelected = true
                }else{
                    supportFilterArr[indexPath.section].value?[ind].isSelected = false
                }
            }
        }else{
            let status = !(supportFilterArr[indexPath.section].value?[indexPath.row].isSelected ?? false)
            supportFilterArr[indexPath.section].value?[indexPath.row].isSelected = status
        }
        tableView.reloadData()
    }
    
    
    
    class func getNewInstance() -> SupportChatFilterViewController? {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SupportChatFilterViewController") as? SupportChatFilterViewController else {
            return nil
        }
        return vc
    }
}



struct SupportFilter {
    var type : FilterHeader = .status
    var value : [SupportFilterValues]?
    
}

struct SupportFilterValues{
    var value : String?
    var isSelected : Bool?
}


enum FilterHeader{
    case status
    case type
    
    func getHeaderValue() -> String{
        switch self {
        case .status:
            return HippoStrings.status
        case .type:
            return HippoStrings.type
        }
    }
    
}


