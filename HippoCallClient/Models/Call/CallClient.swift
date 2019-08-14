
//
//  VideoCallManager.swift
//  HippoCallClient
//
//  Created by Vishal on 03/09/18.
//  Copyright © 2018 Vishal. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

let utcDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()

class CallClient {
    static var shared = CallClient()
    
    // MARK: - Properties
    private(set) var activeCall: Call?
    fileprivate var callPresenter: CallPresenter!
    fileprivate var currentDeviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
    fileprivate let maxTimeInNotConnectedState = 30
    
    fileprivate var credentials: CallClientCredential!
    fileprivate var credentialRetry = 0
    
    // MARK: - Methods
    func setCredentials(rawCredentials: [String: Any]) {
        self.credentials = CallClientCredential(rawCredentials: rawCredentials)
    }
    
    func voipNotificationReceived(dictionary: [AnyHashable: Any], peer: CallPeer, signalingClient: SignalingClient, currentUser: CallPeer) {
        
        guard let jsonDict = dictionary as? [String: Any], let signal = CallSignal.getFrom(json: jsonDict) else {
            return
        }
        
        guard credentials != nil else {
            NSLog("Credential Not found")
            return
        }
        
        let timeout = TimeInterval(maxTimeInNotConnectedState)
        
        func isPushExpired(pushRecievedAt date: Date) -> Bool {
            let currentDate = Date()
            return date.addingTimeInterval(timeout).compare(currentDate) == .orderedAscending
        }
        
        guard
            let dateString = jsonDict["date_time"] as? String,
            let date = utcDateFormatter.date(from: dateString),
            (!isPushExpired(pushRecievedAt: date) || signal.signalType != .startCall) else {
                NSLog("Expired Voip Push received")
                return
        }
        
        let call = Call(peer: peer, signalingClient: signalingClient, uID: signal.callUID, currentUser: currentUser, type: signal.callType)
        
        if !shouldHandle(signal: signal, call: call) {
            print("ERROR -> VOIP PUSH FROM CURRENT USER")
            return
        }
        
        if signal.signalType == .startCall || signal.signalType == .callRejected || signal.signalType == .callHungUp {
            takeActionOnSignalReceived(signal, forCall: call)
        }
        return
    }
    
    func userLoggedOut() {
        callPresenter?.remoteUserRejectedTheCall()
        callDisconnected()
    }
    
    func startConnecting(call: PresentCallRequest, uuid: String) {
        guard !isUserBusy(), credentials != nil else {
            print("Not Ready for Call. Try Again")
            return
        }
        loadCallPresenterView(uuid: uuid, defaultType: call.callType)
        
        //Check if callPresenter is given nil from service user
        guard callPresenter != nil else {
            return
        }
        
        registerCallHungupInCallPresenter()
        registerCallPresenterAccessories()
        callPresenter?.startConnectingCall(request: call, completion: {_ in })
    }
    private func shouldHandle(signal: CallSignal, call: Call) -> Bool {
        guard signal.senderDeviceID != currentDeviceID else {
            return false
        }
        guard signal.sender.peerId == call.currentUser.peerId else {
            return true
        }
        
        guard signal.signalType == .startCall || signal.signalType == .callHungUp || signal.signalType == .callRejected else {
            return false
        }
        
        return true
    }
    
    private func startPublishingLocalNotificationForIncomingCallWith(signal: CallSignal) {
        guard let call = activeCall, activeCall?.status == .idle || activeCall?.status == .incomingCall, signal.callUID == call.uID else {
            return
        }
        callPresenter?.addLocalIncomingCallNotification(peerName: call.peer.name, callType: signal.callType, identifier: call.uID)
        
        HippoDelay(5) {
            self.startPublishingLocalNotificationForIncomingCallWith(signal: signal)
        }
        
    }
    func startNew(call: Call, completion: @escaping (Bool) -> Void) {
        
        guard !isUserBusy(), call.signalingClient.checkIfReadyForCommunication(), credentials != nil else {
            print("Not Ready for Call. Try Again")
            return
        }
        
        activeCall = call
        
        loadCallPresenterView()
        
        //Check if callPresenter is given nil from service user
        guard callPresenter != nil else {
            return
        }
        registerActiveCallsSignallingClient()
        registerCallHungupInCallPresenter()
        registerCallPresenterAccessories()
        
        activeCall?.status = .outgoingCall
        
        let request = PresentCallRequest(peer: call.peer, callType: call.type, callUUID: call.uID)
        callPresenter?.startNewOutgoingCall(request: request) { [weak self] (success) in
            guard success, let weakSelf = self else {
                self?.callDisconnected()
                return
            }
            
            let signal = CallSignal(rtcSignal: [:], signalType: .startCall, callUID: call.uID, sender: call.currentUser, senderDeviceID: weakSelf.currentDeviceID, callType: call.type)
            self?.startTimerToExpireNotConnectedCallIn(signal: signal)
            self?.startSendingStartCallUntilItExpires(signal: signal, call: call)
        }
    }
    private func startSendingStartCallUntilItExpires(signal: CallSignal, call: Call) {
        guard let call = activeCall, call.uID == signal.callUID, call.status != .inCall else {
            return
        }
        
        if call.timeElapsedSinceCallStart > maxTimeInNotConnectedState {
            return
        }
        
        let json = self.credentials.toJson()
        self.sendSignalWith(json: json, signalType: .startCall, call: call)
        HippoDelay(2) {
            self.startSendingStartCallUntilItExpires(signal: signal, call: call)
        }
    }
    
    func sendStartCallSignal(call: Call) {
        let json = self.credentials.toJson()
        self.sendSignalWith(json: json, signalType: .startCall, call: call)
    }
    func hangupCall() {
        self.sendSignalWhenCallHungUp()
        self.callDisconnected()
    }
    func loadCallPresenterView(uuid: String = "", defaultType: Call.CallType = .audio) {
        guard self.callPresenter == nil else {
            return
        }
        let isDialedByUser  = activeCall?.status == Call.State.outgoingCall
        let idString = activeCall?.uID ?? uuid
        guard let id = UUID(uuidString: idString) else {
            return
        }
        let request = CallPresenterRequest.init(uuid: id, callType: activeCall?.type ?? defaultType, isDialedByUser: isDialedByUser)
        self.callPresenter =  HippoCallClient.shared.delgate?.loadCallPresenterView(request: request)
        registerPublishDataInCallPresenter()
    }
    
    // MARK: - Signal Handling
    private func takeActionOnSignalReceived(_ signal: CallSignal, forCall call: Call? = nil) {
        
        //      print("\n \nSignal Received: \(signal.signalType.rawValue) => \(signal.getJsonToSend()) \n \n")
        
        switch signal.signalType {
        case .startCall: //push
            if call != nil {
                startCallReceived(newCall: call!, signal: signal)
            }
            
        case .offer: //signal
            offerReceived(signal: signal)
            
        case .newIceCandidate: //signal
            newIceCandidatesReceived(signal: signal)
            
        case .readyToConnect: //signal
            readyToConnectReceived(signal: signal)
            
        case .answer: //signal
            answerReceived(signal: signal)
            
        case .callHungUp: //signal //push
            callHungupReceived(signal: signal)
            
        case .callRejected:
            callRejectReceived(signal: signal)
            
        case .userBusy: //push
            userBusyReceived(signal: signal)
        case .custom:
            if let customData = signal.customData {
                callPresenter?.newDataRecieved(data: customData)
            }
        }
    }
    
    private func startCallReceived(newCall: Call, signal: CallSignal) {
        if isUserBusy(), activeCall!.uID != newCall.uID { //user busy on another call
            sendSignalWith(json: [:], signalType: .userBusy, call: newCall)
            return
        }
        
        if activeCall == nil {
            activeCall = newCall
            registerActiveCallsSignallingClient()
        }
        
        startPublishingLocalNotificationForIncomingCallWith(signal: signal)
        sendReadyToConnectFor(signal: signal)
        startTimerToExpireNotConnectedCallIn(signal: signal)
    }
    
    private func sendReadyToConnectFor(signal: CallSignal) {
        guard let call = activeCall, call.status == .idle, signal.callUID == call.uID else {
            return
        }
        
        if call.status == .idle {
            let json = credentials.toJson()
            sendSignalWith(json: json, signalType: .readyToConnect, call: call)
        }
        
        HippoDelay(3) {
            self.sendReadyToConnectFor(signal: signal)
        }
    }
    
    private func startTimerToExpireNotConnectedCallIn(signal: CallSignal) {
        guard let call = activeCall, call.uID == signal.callUID, call.status != .inCall else {
            return
        }
        
        if call.timeElapsedSinceCallStart > maxTimeInNotConnectedState {
            expireActiveCall()
            return
        }
        
        HippoDelay(5) {
            call.timeElapsedSinceCallStart += 5
            self.startTimerToExpireNotConnectedCallIn(signal: signal)
        }
    }
    
    private func expireActiveCall() {
        guard let call = activeCall else {
            return
        }
        if shouldPostMissedCallNotificationFor(call: call) {
            postMissedCallNotificationFor(call: call)
        }
        
        if call.status == .outgoingCall {
            sendSignalWhenCallHungUp()
        }
        callPresenter?.remoteUserRejectedTheCall()
        callDisconnected()
    }
    
    private func postMissedCallNotificationFor(call: Call) {
        callPresenter?.addLocalMissedCallNotification(peerName: call.peer.name, callType: call.type, identifier: call.uID)
    }
    
    private func offerReceived(signal: CallSignal) {
        
        func isUserWaitingForOffer() -> Bool {
            guard isUserBusy(), activeCall!.uID == signal.callUID else {
                return false
            }
            return true
        }
        
        guard isUserWaitingForOffer() else {
            return
        }
        
        loadCallPresenterView()
        
        //Check if callPresenter is given nil from service user
        guard callPresenter != nil else {
            return
        }
        registerCallPresenterAccessories()
        registerCallAnsweredInCallPresenter()
        registerCallHungupInCallPresenter()
        
        if activeCall?.rtcClient == nil {
            let request = PresentCallRequest(peer: activeCall!.peer, callType: activeCall!.type, callUUID: activeCall!.uID)
            callPresenter?.reportIncomingCallWith(request: request) { [weak self] (success) in
                guard success, let weakSelf = self else {
                    return
                }
                
                weakSelf.activeCall?.rtcClient = WebRTCClient(delegate: weakSelf, credentials: weakSelf.credentials, isVoiceOnlyCall: weakSelf.activeCall!.type == .audio)
                weakSelf.activeCall?.status = .incomingCall
                weakSelf.activeCall?.rtcClient?.sdpReceivedFromSignalling(json: signal.rtcSignal)
            }
        } else {
            activeCall?.rtcClient?.sdpReceivedFromSignalling(json: signal.rtcSignal)
        }
        
    }
    
    private func callRejectReceived(signal: CallSignal) {
        guard let call = activeCall, call.uID == signal.callUID else {
            return
        }
        
        expireActiveCall()
    }
    
    private func shouldPostMissedCallNotificationFor(call: Call) -> Bool {
        return (call.status == .incomingCall || call.status == .idle) //&& call.type == .video
    }
    
    private func callHungupReceived(signal: CallSignal) {
        guard let call = activeCall, call.uID == signal.callUID else {
            return
        }
        
        if shouldPostMissedCallNotificationFor(call: call) {
            postMissedCallNotificationFor(call: call)
        }
        
        callPresenter?.remoteUserHungUp()
        callDisconnected()
    }
    
    private func newIceCandidatesReceived(signal: CallSignal) {
        guard signal.callUID == activeCall?.uID else {
            return
        }
        activeCall?.rtcClient?.candidateReceivedFromSignalling(json: signal.rtcSignal)
    }
    
    private func readyToConnectReceived(signal: CallSignal) {
        guard let call = activeCall, call.uID == signal.callUID, call.status == .outgoingCall else {
            return
        }
        
        if activeCall?.rtcClient == nil {
            activeCall?.rtcClient = WebRTCClient(delegate: self, credentials: credentials, isVoiceOnlyCall: call.type == .audio)
        }
        
        activeCall?.rtcClient?.startNewCall(completion: { (success) in
            if !success {
                print("RTC failed in Starting New Call ")
            }
        })
    }
    
    func userBusyReceived(signal: CallSignal) {
        guard let call = activeCall, call.uID == signal.callUID, call.status == .outgoingCall else {
            return
        }
        callPresenter?.userBusy()
        callDisconnected()
    }
    
    private func answerReceived(signal: CallSignal) {
        guard activeCall?.rtcClient != nil, activeCall?.uID == signal.callUID, activeCall?.status != .inCall else {
            return
        }
        
        activeCall?.status = .inCall
        activeCall?.rtcClient?.sdpReceivedFromSignalling(json: signal.rtcSignal)
        
        callPresenter?.callConnected()
    }
    
    //MARK: -
    private func registerCallPresenterAccessories() {
        
        registerPauseVideo()
        registerStartVideo()
        registerUnMuteButtonPressed()
        registerMuteButtonPressed()
        registerSwitchCameraInCallPresenter()
        registerLocalAndRemoteViewSwitchAction()
        registerChangeInVideoViewsFrameInCallPresenter()
        registerConfigurationOfAudioSessionInCallPresenter()
        registerAudioSessionActivationAndDeactivation()
        registerSpeakerSwitching()
    }
    private func registerPublishDataInCallPresenter() {
        callPresenter?.publishData = {[weak self] data in
            guard let weakSelf = self, let call = weakSelf.activeCall else {
                return
            }
            self?.sendSignalWith(json: [:], signalType: .custom, call: call, customData: data)
        }
    }
    
    private func registerPauseVideo() {
        callPresenter?.pauseVideoButtonPressed = { [weak self] in
            guard let rtcClient = self?.activeCall?.rtcClient else {
                return false
            }
            rtcClient.pauseVideo()
            return true
        }
    }
    
    private func registerStartVideo() {
        callPresenter?.startVideoButtonPressed = { [weak self] in
            guard let rtcClient = self?.activeCall?.rtcClient else {
                return false
            }
            rtcClient.startVideo()
            return true
        }
    }
    
    private func registerUnMuteButtonPressed() {
        callPresenter?.unMuteAudioButtonPressed = { [weak self] in
            guard let rtcClient = self?.activeCall?.rtcClient else {
                self?.callPresenter?.callMuted()
                return
            }
            
            rtcClient.unmuteAudio(completion: { (success) in
                if success {
                    self?.callPresenter?.callUnMuted()
                } else {
                    self?.callPresenter?.callMuted()
                }
            })
        }
    }
    
    private func registerMuteButtonPressed() {
        callPresenter?.muteAudioButtonPressed = { [weak self] in
            guard let rtcClient = self?.activeCall?.rtcClient else {
                self?.callPresenter?.callUnMuted()
                return
            }
            rtcClient.muteAudio(completion: { (success) in
                if success {
                    self?.callPresenter?.callMuted()
                } else {
                    self?.callPresenter?.callUnMuted()
                }
            })
        }
    }
    
    private func registerCallHungupInCallPresenter() {
        callPresenter?.callHungUp = { [weak self] in
            self?.hangupCall()
        }
    }
    
    private func registerCallAnsweredInCallPresenter() {
        callPresenter?.callAnswered = { [weak self] in
            self?.activeCall?.rtcClient?.incomingCallAnswered()
            self?.activeCall?.status = .inCall
            self?.callPresenter?.callConnected()
        }
    }
    
    private func registerSwitchCameraInCallPresenter() {
        callPresenter?.switchCameraButtonPressed = { [weak self] in
            guard let rtcClient = self?.activeCall?.rtcClient else {
                return false
            }
            rtcClient.switchCamera()
            return true
        }
    }
    
    private func registerLocalAndRemoteViewSwitchAction() {
        callPresenter?.switchRemoteAndLocalVideoViewButtonPressed = { [weak self] in
            self?.activeCall?.rtcClient?.localAndRemoteViewSwitched()
        }
    }
    
    private func registerChangeInVideoViewsFrameInCallPresenter() {
        callPresenter?.frameOfLocalVideoViewChanged = { [weak self] in
            self?.activeCall?.rtcClient?.frameOfLocalVideoContainerViewChanged()
        }
        
        callPresenter?.frameOfRemoteVideoViewChanged = { [weak self] in
            self?.activeCall?.rtcClient?.frameOfRemoteVideoContainerViewChanged()
        }
    }
    
    private func registerConfigurationOfAudioSessionInCallPresenter() {
        callPresenter?.configureAudioSession = {
            WebRTCClient.configureAudioSession()
        }
    }
    
    private func registerAudioSessionActivationAndDeactivation() {
        callPresenter?.audioSessionActivated = { audioSession in
            WebRTCClient.audioSessionDidActivate(audioSession)
        }
        
        callPresenter?.audioSessionDeactivated = { audioSession in
            WebRTCClient.audioSessionDidDeactivate(audioSession)
        }
    }
    
    private func registerSpeakerSwitching() {
        callPresenter?.setAudioOutputToSpeaker = { [weak self] (isSwitchingToSpeaker, completion) in
            guard let rtcClient = self?.activeCall?.rtcClient else {
                completion(false)
                return
            }
            
            rtcClient.changeAudioRouteToSpeaker(isSwitchingToSpeaker, completion: { (success) in
                completion(success)
            })
        }
    }
    
    private func callDisconnected() {
        activeCall?.rtcClient?.endCall()
        activeCall = nil
        callPresenter = nil
    }
    
    private func sendSignalWhenCallHungUp() {
        switch activeCall?.status ?? .idle {
        case .inCall:
            sendSignalWith(json: [:], signalType: .callHungUp, call: activeCall!)
        case .incomingCall:
            sendSignalWith(json: [:], signalType: .callRejected, call: activeCall!)
        case .outgoingCall:
            sendSignalWith(json: [:], signalType: .callHungUp, call: activeCall!)
        case .idle:
            break
        }
    }
    
    private func registerActiveCallsSignallingClient() {
        activeCall?.signalingClient.signalReceivedFromPeer = { [weak self] (jsonDict) in
            guard let signal = CallSignal.getFrom(json: jsonDict),
                let weakSelf = self,
                let call = weakSelf.activeCall,
                weakSelf.shouldHandle(signal: signal, call: call) else {
                    return
            }
            
            self?.takeActionOnSignalReceived(signal)
        }
    }
    
    private func isUserBusy() -> Bool {
        return activeCall != nil
    }
    
    fileprivate func connectionLost() {
        callPresenter?.remoteUserHungUp()
        callDisconnected()
    }
    fileprivate func connectionRetry()  {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.callPresenter?.remoteRetryToConnect()
        }
    }
    
    fileprivate func connected() {
        callPresenter?.remoteConnected()
    }
}

// MARK: - WebRTC Client Delegate
extension CallClient: WebRTCClientDelegate {
    func viewForRenderingLocalVideo() -> UIView? {
        return callPresenter?.viewForLocalVideoRendering()
    }
    
    func viewForRenderingRemoteVideo() -> UIView? {
        return callPresenter?.viewForRemoteVideoRendering()
    }
    
    func sendOfferViaSignalling(json: [String : Any]) {
        callPresenter?.sendingOffer()
        sendSignalWith(json: json, signalType: .offer, call: activeCall!)
    }
    
    func sendAnswerViaSignalling(json: [String : Any]) {
        sendSignalWith(json: json, signalType: .answer, call: activeCall!)
    }
    
    func sendCandidateViaSignalling(json: [String : Any]) {
        sendSignalWith(json: json, signalType: .newIceCandidate, call: activeCall!)
    }
    
    func sendSignalWith(json: [String: Any], signalType: CallSignal.SignalType, call: Call, customData: CustomData? = nil) {
        var signal = CallSignal(rtcSignal: json, signalType: signalType, callUID: call.uID, sender: call.currentUser, senderDeviceID: currentDeviceID, callType: call.type)
        
        //For Sending multiole start call sliently
        signal.isForceSilent = call.isStartCallSend
        signal.customData = customData
        
        call.isStartCallSend = true
        
        call.signalingClient.connectClient(completion: { (success) in
            call.signalingClient.sendSignalToPeer(signal: signal, completion: { (success, error) in
                if !success {
                    NSLog("UNABLE TO SEND SIGNAL")
                    
                    if self.credentialRetry > 10 {
                        NSLog("Crendential retries expired to send signal")
                        self.credentialRetry = 0
                        return
                    }
                    
                    if let userInfo = error?.userInfo[NSLocalizedFailureReasonErrorKey] as? [String: Any],
                        let data = userInfo["data"] as? [String: Any],
                        let credential = CallClientCredential(rawCredentials: data) {
                        self.credentials = credential
                        self.credentialRetry += 1
                        self.sendSignalWith(json: credential.toJson(), signalType: signalType, call: call)
                    }
                    
                } else {
                    self.credentialRetry = 0
                    //               print("\n \n Signal Sent: \(signal.signalType.rawValue) => \(signal.getJsonToSend()) \n \n")
                }
            })
            
        })
    }
    
    func rtcConnectionDisconnected() {
        self.connectionLost()
    }
    func rtcConnectionRetry() {
        self.connectionRetry()
    }
    
    func rtcConnecetd() {
        self.connected()
    }
}
