//
//  PagerViewController.swift
//  SDKDemo1
//
//  Created by cl-macmini-67 on 03/02/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

protocol AllConversationTableViewDelegate {
    func didSelect(withObject obj: FuguConversation)
    func EmptyHeaderAction(_ sender: UITapGestureRecognizer)
    func refreshTable(_ refreshControl: UIRefreshControl)
    func tableViewDidScroll(_ scrollView: UIScrollView, index: Int)
    
}

enum FilterChatBy {
    case filterByChatType
    case filterByKey
}


class PagerViewController: ButtonBarPagerTabStripViewController {
    
    struct TypeStruct {
        var filterKey: String!
        var filterChatBy: FilterChatBy!
        
        init(filterKey: String, filterChatBy: FilterChatBy) {
            self.filterKey = filterKey
            self.filterChatBy = filterChatBy
        }
    }
    
    var scrollOffsetOFControllers = [CGPoint]()
    var shouldRemoveAllOffset = true
   
    
    override func viewDidLoad() {
        self.setupUI()
        super.viewDidLoad()
        buttonBarView.selectedBar.backgroundColor = .orange
        buttonBarView.backgroundColor = .white
        let vw = UIView()
        vw.frame = CGRect(x: 0, y: buttonBarView.bounds.height, width: self.view.bounds.width, height: 1.0)
        vw.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        self.view.addSubview(vw)
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = HippoConfig.shared.theme.buttonBarItemTitleColor
            oldCell?.label.font = HippoConfig.shared.theme.buttonBarItemFont
            newCell?.label.textColor = HippoConfig.shared.theme.buttonBarSelectedTitleColor
            newCell?.label.font = HippoConfig.shared.theme.buttonBarSelectedItemFont
        }
    }
    
    //MARK: UISETUP
    
    func setupUI() {
        settings.style.buttonBarBackgroundColor = HippoConfig.shared.theme.buttonBarBackgroundColor
        settings.style.buttonBarMinimumInteritemSpacing = HippoConfig.shared.theme.buttonBarMinimumInteritemSpacing
        settings.style.selectedBarBackgroundColor = HippoConfig.shared.theme.selectedBarBackgroundColor
        settings.style.selectedBarHeight = HippoConfig.shared.theme.selectedBarHeight
        settings.style.buttonBarItemBackgroundColor = HippoConfig.shared.theme.buttonBarItemBackgroundColor
        settings.style.buttonBarItemFont = HippoConfig.shared.theme.buttonBarItemFont
        settings.style.buttonBarItemLeftRightMargin = HippoConfig.shared.theme.buttonBarItemLeftRightMargin
        settings.style.buttonBarItemTitleColor = HippoConfig.shared.theme.buttonBarItemTitleColor

        //        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
//        settings.style.buttonBarMinimumLineSpacing: CGFloat?
        // buttonBar flow layout left content inset value
//        settings.style.buttonBarLeftContentInset: CGFloat?
        // buttonBar flow layout right content inset value
//        settings.style.buttonBarRightContentInset: CGFloat?

    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let storyBoard = UIStoryboard.init(name: "FuguUnique", bundle: HippoFlowManager.bundle)

        guard let parent = self.parent as? AllConversationsViewController else {
            let item = storyBoard.instantiateViewController(withIdentifier: "ConversationListTableViewController") as! ConversationListTableViewController
            return [item]
        }

        var controllerArray = [UIViewController]()
        var arrForControllers = [[FuguConversation]]()
        var filters = [TypeStruct]()
        
        if shouldRemoveAllOffset {
            self.scrollOffsetOFControllers.removeAll()
            self.shouldRemoveAllOffset = false
        }
        
        for (i,value) in HippoConfig.shared.allConversationTypes.enumerated() {
            
            if self.scrollOffsetOFControllers.count != HippoConfig.shared.allConversationTypes.count {
                scrollOffsetOFControllers.append(CGPoint.init(x: 0, y: 0))
            }
            
            if i == 0 {
                arrForControllers.append(parent.arrayOfConversation)
            } else {
                arrForControllers.append([FuguConversation]())
            }
            
            var filterKey = value["key"] as? String ?? ""
            var filterType: FilterChatBy = .filterByKey
            if let filter_by_chat_type = value["filter_by_chat_type"] as? Bool {
                if filter_by_chat_type {
                    filterType = .filterByChatType
                    if let key = value["chat_type_filter_value"] as? Int {
                        filterKey = "\(key)"
                    } else {
                        filterKey = ""
                        
                    }
                    
                }
            }
            
            filters.append(TypeStruct.init(filterKey: filterKey, filterChatBy: filterType))
            
        }
        
        for obj in parent.arrayOfConversation {
            for (index,value) in filters.enumerated() {
                if index != 0 {
                    if shouldShowObj(obj, filterType: value.filterChatBy, filterKey: value.filterKey) {
                        arrForControllers[index].append(obj)
                    }
                }
            }
            
        }
        
        for (i,value) in arrForControllers.enumerated() {
            
            if value.isEmpty {
                let item = storyBoard.instantiateViewController(withIdentifier: "EmptyViewPlaceholderViewController") as! EmptyViewPlaceholderViewController
                item.itemInfo = IndicatorInfo.init(title: HippoConfig.shared.allConversationTypes[i]["values"] as? String)
                controllerArray.append(item)
                
            } else {
                let item = storyBoard.instantiateViewController(withIdentifier: "ConversationListTableViewController") as! ConversationListTableViewController
                item.setData(itemInfo: IndicatorInfo.init(title: HippoConfig.shared.allConversationTypes[i]["values"] as? String), data: value, tableViewDefaultText: parent.tableViewDefaultText, indexOfController: i, offset: self.scrollOffsetOFControllers[i])
                item.delegate = self
                controllerArray.append(item)
            }
            
        }
        
        
        return controllerArray
    }
    
    func shouldShowObj(_ convObj: FuguConversation, filterType: FilterChatBy, filterKey: String) -> Bool {
        switch filterType {
        case .filterByKey:
            if filterKey != "" {
                if let transactionId = convObj.transactionId {
                    let components = transactionId.components(separatedBy: "_")
                    if components.count == 0 {  return false }
                    if components.last != filterKey { return false }
                } else {
                    return false
                }
            }
        default:
            if filterKey != "" {
                if let chatType = convObj.chatType {
                    return chatType == Int(filterKey)!
                } else {
                    return false
                }
            }
        }
        
        
        
        return true
    }

    
    override func reloadPagerTabStripView() {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: true, elasticIndicatorLimit: true )
            super.reloadPagerTabStripView()
    }
    
    func reloadData() {
        
    }
    
    override func moveTo(viewController: UIViewController, animated: Bool) {
        
    }
    
    
}

extension PagerViewController: AllConversationTableViewDelegate {
    func tableViewDidScroll(_ scrollView: UIScrollView, index: Int) {
        self.scrollOffsetOFControllers[index] = scrollView.contentOffset
    }
    
    func didSelect(withObject obj: FuguConversation) {
        guard let parent = self.parent as? AllConversationsViewController else {
            return
        }
            parent.openChat(withObj: obj)
    }
    
    func EmptyHeaderAction(_ sender: UITapGestureRecognizer) {
        guard let parent = self.parent as? AllConversationsViewController else {
            return
        }
            parent.EmptyheaderAction(sender)
    }
    
    func refreshTable(_ refreshControl: UIRefreshControl) {
        guard let parent = self.parent as? AllConversationsViewController else {
            return
        }
        parent.refresh(refreshControl)
    }
}
