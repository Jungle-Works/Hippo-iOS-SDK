//
//  CallKitManager.swift
//  Hippo
//
//  Created by soc-admin on 03/01/22.
//

import Foundation
import CallKit
import os

#if canImport(HippoCallClient)
import HippoCallClient
#endif

#if canImport(HippoCallClient)
class CallKitManager: NSObject, CXProviderDelegate {
    
    static let shared = CallKitManager()
    
    // MARK: - Properties
    private static var provider: CXProvider = {
        let nameOfApp = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Hippo"
        let configuration = CXProviderConfiguration(localizedName: nameOfApp)
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
//        configuration.ringtoneSound = "incoming_call.mp3"
        configuration.supportsVideo = true
        let provider = CXProvider(configuration: configuration)
        return provider
    }()
    
    private var provider = CallKitManager.provider
    private var callKitController = CXCallController()
    
    // MARK: - Intializer
    override init() {
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    // MARK: - Methods
    func reportIncomingCallWith(
        request: PresentCallRequest,
        completion: @escaping () -> Void
    ) {

        guard let uuid = UUID(uuidString: request.callUuid) else {
            completion()
            return
        }

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: request.peer.name)
        update.localizedCallerName = request.peer.name
        update.hasVideo = request.callType == .video
        update.supportsDTMF = false
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false

        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                os_log(.error, "❌ CallKit incoming error: %{public}@", error.localizedDescription)
            }
            completion()
        }

        HippoCallClient.shared.updateProviderInJitsi(with: provider)
    }

    
    func startNewOutgoingCall(request: PresentCallRequest, completion: @escaping (Bool) -> Void) {
        if #available(iOS 12.0, *) {
            os_log(.error, "OS_HIPPO>>>", "startNewOutgoingCall")
        }

        let handle = CXHandle(type: .generic, value: request.peer.name)
        let startCallAction = CXStartCallAction(call: UUID(uuidString: request.callUuid) ?? UUID(), handle: handle)
        let transaction = CXTransaction(action: startCallAction)

        callKitController.request(transaction) { [weak self] (error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Call Kit Error in starting call -> \(error.debugDescription)")
                    completion(false)
                    return
                }
                self?.provider.reportOutgoingCall(with: UUID(uuidString: request.callUuid) ?? UUID(), connectedAt: Date())
                completion(true)
            }
        }
        HippoCallClient.shared.updateProviderInJitsi(with: self.provider)
    }
    
  
    func endCall(uuid: UUID) {
        let endAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endAction)

        callKitController.request(transaction) { error in
            if let error = error {
                os_log(.error, "❌ End call failed: %{public}@", error.localizedDescription)
            }
        }
    }



    // MARK: - CXProviderDelegate
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        HippoCallClient.shared.actionFromCallKit(isAnswered: false, completion: { _ in })
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        HippoCallClient.shared.actionFromCallKit(isAnswered: true) { success in
            success ? action.fulfill() : action.fail()
        }
    }
    
    func providerDidReset(_ provider: CXProvider) {}
    
    
    // MARK: - Deinitializer
    deinit {
        print("Audio Call presenter deintialized")
    }
}



#endif
