//
//  NewAllConversationViewController.swift
//  Hippo
//
//  Created by Neha on 20/11/24.
//

import Foundation
import UIKit



class NewAllConversationViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UIView!
    
    var config: AllConversationsConfig = AllConversationsConfig.defaultConfig
    var arrayOfConversation = [FuguConversation]()
    override func viewDidLoad() {
        setTableView()
        getAllConversations()
    }
    
    func setTableView() {
        let bundle = FuguFlowManager.bundle
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ConversationView", bundle: bundle), forCellReuseIdentifier: "ConversationCellCustom")
    }
    
    func getAllConversations() {
        arrayOfConversation = []
        
        FuguConversation.getAllConversationFromServer(config: config) { [weak self] (result) in
            var conversation = result.conversations!
            if self?.config.isStaticRemoveConversation ?? false, let status = self?.config.enabledChatStatus, !status.isEmpty {
                let lastChannelId = self?.config.lastChannelId ?? -12
                conversation = conversation.filter({ (con) -> Bool in
                    return (status.contains(con.channelStatus) && lastChannelId != con.channelId)
                })
            }
            
            
            self?.arrayOfConversation = conversation
            print(self?.arrayOfConversation.count)
            self?.tableView.reloadData()
        }
    }
}
extension NewAllConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfConversation.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationView", for: indexPath) as? ConversationView else {
        //            return UITableViewCell()
        //        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCellCustom", for: indexPath) as? ConversationView else {
            return UITableViewCell()
        }
        
        
        let convObj = arrayOfConversation[indexPath.row]
        cell.configureConversationCell(resetProperties: true, conersationObj: convObj)
        return cell
    }
}
