//
//  HippoHomeViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 19/09/18.
//

import UIKit

class HippoHomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didSetUserChannel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeUserChannelNotification()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func subscribeUserChannelNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didSetUserChannel), name: .userChannelChanged, object: nil)
    }
    
    
    //MARK: Function to override
    @objc func didSetUserChannel() { }
    func deleteConversation(channelId: Int) { }

    func channelStatusChanged(channelId: Int, newStatus: ChatStatus) {
        fuguDelay(1) {
            self.deleteConversation(channelId: channelId)
        }
    }
}
