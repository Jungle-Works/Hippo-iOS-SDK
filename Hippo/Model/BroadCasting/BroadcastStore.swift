//
//  BroadcastStore.swift
//  Hippo
//
//  Created by Vishal on 20/02/19.
//

import Foundation


protocol BroadcastStoreDelegate: class {
    func broadcastsUpdated(broadcasts: [BroadcastInfo])
    func showPaginationLoader()
    func hideLoader()
}

class BroadcastStore: NSObject {
    
    var broadcasts: [BroadcastInfo] = []
    var manager = BroadcastManager()
    var canLoadMoreBroadcast: Bool = true
    
    weak var delegate: BroadcastStoreDelegate?
    
    
    override init() {
        super.init()
        fetchBroadcastsFromCache()
//        getBroadcastFromInital()
    }
    
    deinit {
        storeBroadcastsToCache()
    }
    
    func fetchBroadcastsFromCache() {
        
    }
    
    func storeBroadcastsToCache() {
        
    }
    
    func getBroadcastFromInital(completion: ((_ list: [BroadcastInfo]?) -> ())? = nil) {
        let request = BroadcastManager.Request(offset: 0)
        getBroadcast(request: request) {[weak self] (result) in
            guard let parsedResult = result else {
                completion?(nil)
                return
            }
            
            self?.broadcasts = parsedResult
            self?.delegate?.broadcastsUpdated(broadcasts: parsedResult)
            completion?(parsedResult)
        }
    }
    private func getBroadcast(request: BroadcastManager.Request, completion: @escaping (([BroadcastInfo]?) -> ())) {
        var newRequest = request
        newRequest.showLoader = broadcasts.isEmpty
        manager.getBroadcastsFor(request: newRequest) {[weak self] (response) in
            guard let result = response.channels, response.sccuess else {
                completion(nil)
                return
            }
            self?.canLoadMoreBroadcast = response.canLoadMoreData
            completion(result)
        }
    }
    func getMoreBroadcast() {
        guard canLoadMoreBroadcast else {
            return
        }
        canLoadMoreBroadcast = false
        delegate?.showPaginationLoader()
        let request = BroadcastManager.Request(offset: broadcasts.count)
        getBroadcast(request: request) {[weak self] (result) in
            self?.delegate?.hideLoader()
            guard let parsedResult = result, let weakself = self else {
                return
            }
            weakself.broadcasts.append(contentsOf: parsedResult)
            self?.delegate?.broadcastsUpdated(broadcasts: weakself.broadcasts)
        }
    }
}
