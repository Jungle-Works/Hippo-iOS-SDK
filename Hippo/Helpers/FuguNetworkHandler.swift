//
//  FuguNetworkHandler.swift
//  Fugu
//
//  Created by clickpass on 7/11/17.
//

import UIKit
import NotificationCenter


extension Notification.Name {
    public static var internetDisconnected = Notification.Name.init("internetDisconnected")
    public static var internetConnected = Notification.Name.init("internetConnected")
}



class FuguNetworkHandler: NSObject {
   
   static let shared = FuguNetworkHandler()
   
    let reachability = NetworkReachabilityManager()
    
    var isNetworkConnected: Bool {
        return reachability?.isReachable ?? true
    }
    
    func fuguConnectionChangesStartNotifier() {
        
        
        reachability?.listener = { [weak self] (status) in
            guard let weakSelf = self else {
                return
            }
            switch status {
            case .notReachable:
//                print(">>>>>>disconnected")
                NotificationCenter.default.post(name: .internetDisconnected, object: nil)
                weakSelf.errorMessage(errorLabelColor: UIColor.red, needToBeHidden: false)
            default:
                NotificationCenter.default.post(name: .internetConnected, object: nil)
//                print(">>>>>>connected")
                
                weakSelf.errorMessage(errorLabelColor: UIColor.orange, errorLabelMessage: HippoStrings.connecting, isToLoadFirstTime: false, needToBeHidden: false)
                if SocketClient.shared.isConnected() == true {
                    fuguDelay(0.5, completion: {
                        weakSelf.updateConnectedStatus()
                    })
                } else {
                    fuguDelay(0.5, completion: {
                        weakSelf.updateConnectedStatus()
                    })
                }
            }
        }
        
        reachability?.startListening()
        
        //declare this property where it won't go out of scope relative to your listener
//        reachability.whenReachable = { [weak self] fuguConnection in
//
//         guard let weakSelf = self else {
//            return
//         }
//         NotificationCenter.default.post(name: .internetConnected, object: nil)
//            print(">>>>>>connected")
//
//            weakSelf.errorMessage(errorLabelColor: UIColor.orange, errorLabelMessage: "Connecting...", isToLoadFirstTime: false, needToBeHidden: false)
//                if FayeConnection.shared.isConnected == true {
//                    fuguDelay(0.5, completion: {
//                        weakSelf.updateConnectedStatus()
//                    })
//                } else {
//                    fuguDelay(0.5, completion: {
//                        weakSelf.updateConnectedStatus()
//                    })
//                }
//
//        }
//        reachability.whenUnreachable = { [weak self] _ in
//            print(">>>>>>disconnected")
//            NotificationCenter.default.post(name: .internetDisconnected, object: nil)
//            self?.errorMessage(errorLabelColor: UIColor.red, needToBeHidden: false)
//        }
        
//        do { try reachability.startNotifier() }
//        catch { print("Unable to start notifier") }
    }
    
    
    fileprivate func updateConnectedStatus() {
        
        self.errorMessage(errorLabelColor: HippoConfig.shared.theme.processingGreenColor, errorLabelMessage: HippoStrings.connected, isToLoadFirstTime: false, needToBeHidden: false)
            fuguDelay(0.5, completion: {
                self.errorMessage(errorLabelColor: HippoConfig.shared.theme.processingGreenColor, errorLabelMessage: HippoStrings.connected,  needToBeHidden: true)
            })
    }
    
    fileprivate func errorMessage(errorLabelColor: UIColor? = nil, errorLabelMessage: String = "", isToLoadFirstTime: Bool = true, needToBeHidden hidden: Bool) {
        let erorMessage = errorLabelMessage.isEmpty ? HippoStrings.noNetworkConnection : errorLabelMessage
        if let chatBoxVC = getLastVisibleController() as? ConversationsViewController, chatBoxVC.isViewLoaded {
            if hidden == false {
                chatBoxVC.errorLabel.text = erorMessage
            }
            if let color = errorLabelColor {
                chatBoxVC.errorLabel.backgroundColor = color
            } else {
                chatBoxVC.errorLabel.backgroundColor = UIColor.red
            }
            if !isToLoadFirstTime && chatBoxVC.height_errorView.constant == 0 {
                chatBoxVC.errorLabel.backgroundColor = UIColor.red
                chatBoxVC.updateErrorLabelView(isHiding: true)
            } else {
                chatBoxVC.updateErrorLabelView(isHiding: hidden)
            }
            
            if hidden {
                chatBoxVC.internetIsBack()
            }
        }else if let chatBoxVC = getLastVisibleController() as? PromotionsViewController, chatBoxVC.isViewLoaded {
            if hidden == false {
                chatBoxVC.errorLabel.text = erorMessage
            }
            if let color = errorLabelColor {
                chatBoxVC.errorLabel.backgroundColor = color
            } else {
                chatBoxVC.errorLabel.backgroundColor = UIColor.red
            }
            if !isToLoadFirstTime && chatBoxVC.viewError_Height.constant == 0 {
                chatBoxVC.errorLabel.backgroundColor = UIColor.red
                chatBoxVC.updateErrorLabelView(isHiding: true)
            } else {
                chatBoxVC.updateErrorLabelView(isHiding: hidden)
            }
            
            if hidden {
                if chatBoxVC.viewError_Height.constant != 0{
                    chatBoxVC.updateErrorLabelView(isHiding: hidden)
                    chatBoxVC.callGetAnnouncementsApi()
                }
            }
        }else if let conversationVC = getLastVisibleController() as? AllConversationsViewController, conversationVC.isViewLoaded {
            if hidden == false {
                
                guard let chatCachedArray = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]], chatCachedArray.isEmpty == false else {
                    
                    return
                }
                
                conversationVC.refreshControl.endRefreshing()
                
                conversationVC.errorLabel.text = erorMessage
                if let color = errorLabelColor {
                    conversationVC.errorLabel.backgroundColor = color
                } else {
                    conversationVC.errorLabel.backgroundColor = UIColor.red
                }
                
                if !isToLoadFirstTime && conversationVC.height_ErrorLabel.constant == 0 {
                    conversationVC.errorLabel.backgroundColor = UIColor.red
                    conversationVC.updateErrorLabelView(isHiding: true)
                } else {
                    conversationVC.updateErrorLabelView(isHiding: hidden)
                }
            } else {
                conversationVC.getAllConversations()
                conversationVC.updateErrorLabelView(isHiding: hidden)
            }
        }else if let agentVC = getLastVisibleController() as? AgentHomeViewController, agentVC.isViewLoaded {
            if hidden == false {
                
//                guard let chatCachedArray = FuguDefaults.object(forKey: DefaultName.conversationData.rawValue) as? [[String: Any]], chatCachedArray.isEmpty == false else {
//
//                    return
//                }
                
 //               agentVC.refreshControl.endRefreshing()
                
                agentVC.errorLabel.text = erorMessage
                if let color = errorLabelColor {
                    agentVC.errorLabel.backgroundColor = color
                } else {
                    agentVC.errorLabel.backgroundColor = UIColor.red
                }
                
                if !isToLoadFirstTime && agentVC.height_ErrorLabel.constant == 0 {
                    agentVC.errorLabel.backgroundColor = UIColor.red
                    agentVC.updateErrorLabelView(isHiding: true)
                } else {
                    agentVC.updateErrorLabelView(isHiding: hidden)
                }
            } else {
                AgentConversationManager.getAllData()
                agentVC.updateErrorLabelView(isHiding: hidden)
            }
        }
    }
    
//    func connectedToNetwork() -> Bool {
//        return reachability?.connection != .none
//    }
}
