//
//  ConversationListTableViewController.swift
//  SDKDemo1
//
//  Created by cl-macmini-67 on 03/02/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ConversationListTableViewController: UITableViewController, IndicatorInfoProvider {
    
    var itemInfo = IndicatorInfo(title: "View")
    var data = [FuguConversation]()
    var filteredData = [FuguConversation]()
    var tableViewDefaultText = ""
    var delegate:AllConversationTableViewDelegate? = nil
    var indexOfController = 0
    var offset = CGPoint.init(x: 0, y: 0)
    
    func setData(itemInfo: IndicatorInfo, data: [FuguConversation], tableViewDefaultText: String, indexOfController: Int, offset: CGPoint) {
        self.itemInfo = itemInfo
        self.data = data
        self.tableViewDefaultText = tableViewDefaultText
       self.offset = offset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.backgroundView = refreshControl
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.tableView.setContentOffset(self.offset, animated: false)
        }
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        if let classDelegate = self.delegate {
            classDelegate.refreshTable(refreshControl)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helper
    
    
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    // MARK: - Table view data source

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationView", for: indexPath) as? ConversationView  else {
            return UITableViewCell()
        }
        let convObj = data[indexPath.row]
        cell.configureConversationCell(resetProperties: true, conersationObj: convObj)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ConversationView else { return }
        cell.selectionView.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ConversationView else { return }
        cell.selectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return 30 }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        tableView.isScrollEnabled = true
        guard data.count > 0 else {
            tableView.isScrollEnabled = false
            return tableView.frame.height
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: tableView.frame.size.height)
        
        let footerLabel:UILabel = UILabel(frame: CGRect(x: 0, y: (tableView.frame.height / 2) - 90, width: tableView.frame.width, height: 90))
        footerLabel.textAlignment = NSTextAlignment.center
        footerLabel.textColor = #colorLiteral(red: 0.3490196078, green: 0.3490196078, blue: 0.4078431373, alpha: 1)
        footerLabel.numberOfLines = 0
        footerLabel.font = UIFont.systemFont(ofSize: 16.0)
        
        footerLabel.text = tableViewDefaultText
        
        footerView.addSubview(footerLabel)
        
        let emptyAction = UITapGestureRecognizer(target: self, action: #selector(headerEmptyAction(_:)))
        footerView.addGestureRecognizer(emptyAction)
        
        return footerView
    }
    
    @objc func headerEmptyAction(_ sender: UITapGestureRecognizer) {
        if let classDelegate = self.delegate {
            classDelegate.EmptyHeaderAction(sender)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //        tableView.isUserInteractionEnabled = false
        //        fuguDelay(1) {
        //            tableView.isUserInteractionEnabled = true
        //        }
        
        let conversationObj = data[indexPath.row]
        
        if let classDelegate = self.delegate {
            classDelegate.didSelect(withObject: conversationObj)
        }
        
        if let unreadCount = conversationObj.unreadCount, unreadCount > 0 {
            
            conversationObj.unreadCount = 0
            _ = checkUnreadChatCount()
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

}

extension ConversationListTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let classDelegate = self.delegate {
            classDelegate.tableViewDidScroll(scrollView, index: self.indexOfController)
        }
    }
}
