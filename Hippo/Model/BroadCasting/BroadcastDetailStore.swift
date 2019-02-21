//
//  BroadcastDetailStore.swift
//  Fugu
//
//  Created by Vishal on 11/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation

protocol BroadcastDetailStoreDelegate: class {
    func usersListUpdated(users: [CustomerInfo])
    func showPaginationLoader()
    func hideLoader()
}

class BroadcastDetailStore: NSObject {
    var broadcast: BroadcastInfo
    var manager = BroadcastManager()
    var canLoadMoreUsers: Bool = false
    var users: [CustomerInfo] = []
    weak var delegate: BroadcastDetailStoreDelegate?
    
    init(broadcastDetail: BroadcastInfo) {
        self.broadcast = broadcastDetail
    }
    
    
    func getStatusFromInital() {
        let initalRequest = BroadcastManager.Request(offset: 0, channelID: broadcast.channelId)
        
        getStatus(request: initalRequest) {[weak self] (users) in
            guard let parsedUsers = users else {
                return
            }
            self?.users = parsedUsers
            self?.delegate?.hideLoader()
            self?.delegate?.usersListUpdated(users: parsedUsers)
        }
    }
    
    
    private func getStatus(request: BroadcastManager.Request, completion: @escaping (([CustomerInfo]?) -> ())) {
        var newRequest = request
        newRequest.showLoader = users.isEmpty
        
        manager.getBroadcastStatus(request: newRequest) {[weak self] (response) in
            guard let result = response.users, response.sccuess else {
                completion(nil)
                return
            }
            self?.canLoadMoreUsers = response.canLoadMoreData
            completion(result)
        }
    }
    func getMoreUsers() {
        guard canLoadMoreUsers else {
            return
        }
        
        canLoadMoreUsers = false
        delegate?.showPaginationLoader()
        
        let request = BroadcastManager.Request(offset: users.count, channelID: broadcast.channelId)
        getStatus(request: request) {[weak self] (result) in
            self?.delegate?.hideLoader()
            guard let parsedResult = result, let weakself = self else {
                return
            }
            weakself.users.append(contentsOf: parsedResult)
            self?.delegate?.usersListUpdated(users: weakself.users)
        }
    }
}
