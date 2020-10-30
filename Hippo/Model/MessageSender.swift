//
//  MessageSender.swift
//  SDKDemo1
//
//  Created by Vishal on 28/08/18.
//

import Foundation

protocol MessageSenderDelegate: class {
    func messageSent(message: HippoMessage)
    func messageExpired(message: HippoMessage)
    func duplicateMuidOf(message: HippoMessage)
    func subscribeChannel(completion: @escaping (_ success: Bool) -> Void)
    func messageSendingFailed(message: HippoMessage, result: SocketClient.EventAckResponse)
}

class MessageSender {
    
    static let messageExpiryTime: TimeInterval = 10 * 60
    
    // MARK: - Properties
    var messagesToBeSent: [HippoMessage]
    let channelID: Int
    weak var delegate: MessageSenderDelegate!
    var isSendingMessages = false
    
    // MARK: - Intializer
    init(messagesToSend: [HippoMessage], forChannelID channelID: Int, delegate: MessageSenderDelegate) {
        
        self.messagesToBeSent = messagesToSend
        self.channelID = channelID
        self.delegate = delegate
        isSendingMessages = true
        startSending()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fayeConnected), name: .channelSubscribed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fayeConnected), name: .socketConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fayeDisconnected), name: .internetDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fayeDisconnected), name: .socketDisconnected, object: nil)
    }
    
    // MARK: - Methods
    func addMessagesInQueueToSend(message: HippoMessage) {
        messagesToBeSent.append(message)
        if !isSendingMessages {
            isSendingMessages = true
            startSending()
        }
    }
    
    @objc func fayeConnected() {
        if !isSendingMessages, SocketClient.shared.isChannelSubscribed(channel: channelID.description) {
            isSendingMessages = true
            startSending()
        }
    }
    
    @objc func fayeDisconnected() {
        isSendingMessages = false
    }
    
    private func startSending() {
        
        guard let message = messagesToBeSent.first, isSendingMessages else {
            isSendingMessages = false
            return
        }
        
        guard (message.status == .none || message.type == .feedback || message.type == .consent || message.type == .card || message.type == .multipleSelect) && !message.isDeleted else {
            messagesToBeSent.removeFirst()
            startSending()
            return
        }
        
        guard (!message.isMessageExpired() && message.isSentByMe()) || message.type == .feedback || message.type == .consent || message.type == .card || message.type == .multipleSelect else {
            invalidateCurrentMessageWhichIsBeingSent()
            self.isSendingMessages = true
            startSending()
            return
        }
        message.wasMessageSendingFailed = false
        
//        guard FayeConnection.shared.isChannelSubscribed(channelID: channelID.description) else {
//            isSendingMessages = false
//            return
//        }
        
        let messageJSON: [String: Any]
        
        switch message {
        case let customMessage as HippoActionMessage:
            messageJSON = customMessage.getJsonToSendToFaye()
        default:
            messageJSON = message.getJsonToSendToFaye()
        }
        
        SocketClient.shared.send(messageDict: messageJSON, toChannelID: channelID.description, completion: { [weak self] (result) in
            
            
            if result.isSuccess {
                guard self?.messagesToBeSent.count != 0 else {
                    self?.isSendingMessages = false
                    return
                }
                message.status = .sent
                SoundPlayer.messageSentSucessfully()
                DispatchQueue.main.async {
                    self?.delegate?.messageSent(message: message)
                }
                self?.messagesToBeSent.removeFirst()
                self?.startSending()
                HippoConfig.shared.log.debug("-->\(self?.channelID.description ?? "no channel id") == messageSent == \(messageJSON) ", level: .socket)
            } else {
                print("FayeConnection.shared.send****:", result.error)
                guard let errorType = result.error else {
                    self?.retryWithDelay()
                    return
                }
                
                switch errorType {
                case .duplicateMuid:
                    self?.delegate?.duplicateMuidOf(message: message)
                case .userBlocked, .messageDeleted, .userDoesNotBelongToChannel:
                    self?.invalidateCurrentMessageWhichIsBeingSent()
                case .channelNotSubscribed:
                    self?.delegate.subscribeChannel(completion: { (success) in
                        self?.retryWithDelay(/*0*/)
                    })
                    return
                case .invalidSending:
                    self?.messageSendingFailed(result: result)
                    
                case .resendSameMessage:
                    message.status = .sent
                    if self?.messagesToBeSent.count ?? 0 > 0 {
                        self?.messagesToBeSent.removeFirst()
                    }
                    break
                case .personalInfoSharedError:
                    self?.messageSendingFailed(result: result)
                default:
                    break
                }
                
                self?.retryWithDelay()
            }
        })
    }
    
    func clearMessagesToBeSent() {
        isSendingMessages = false
        messagesToBeSent.removeAll()
    }
    
    private func invalidateCurrentMessageWhichIsBeingSent() {
        guard let message = messagesToBeSent.first else {
            return
        }
        
        message.wasMessageSendingFailed = true
        message.status = .none
        
        messagesToBeSent.removeFirst()
        DispatchQueue.main.async {
            self.delegate?.messageExpired(message: message)
        }
    }
    private func messageSendingFailed(result: SocketClient.EventAckResponse) {
        guard let message = messagesToBeSent.first else {
            return
        }
        
        message.wasMessageSendingFailed = true
        message.status = .none
        
        messagesToBeSent.removeFirst()
        DispatchQueue.main.async {
            self.delegate?.messageSendingFailed(message: message, result: result)
        }
    }
    private func retryWithDelay(_ delay: TimeInterval = 5) {
        // delay to wait before retrying
        fuguDelay(delay, completion: { [weak self] in
            self?.startSending()
        })
    }
}

private extension HippoMessage {
    func isMessageExpired() -> Bool {
        let expiryDate = self.creationDateTime.addingTimeInterval(MessageSender.messageExpiryTime)
        
        return expiryDate.compare(Date()) == ComparisonResult.orderedAscending
    }
}

