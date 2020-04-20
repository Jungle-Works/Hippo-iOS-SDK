//
//  PermissionManager.swift
//  HippoDemo
//
//  Created by Vishal on 26/06/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

struct MicAndCameraPermissionResponse {
    var isDenied: Bool = false
    var message: String = ""
}

enum CallType: Int {
    case `in`
    case `out`
}

enum PermissionType: Int {
    case mic
    case camera
    case both
}

class PermissionManager {
    var premissionType: PermissionType = .mic
    var callType: CallType = .out
    
    init() {
        
    }
    
    init(with permission: PermissionType, call type: CallType) {
        premissionType = permission
        callType = type
    }
    
    let micMessageToInCall = "TO answer calls, Hipponeeds access to your iphone's microphone. tap settings and turn on microphone."
    let micMessageToInOutCall = "TO place calls, Hipponeeds access to your iPhone's microphone. Tap settings and turn on microphone."
    let cameraMessageToOutCall = "To Place calls, Hipponeeds access to your iPhone's camera. Tap setting and turn on camera."
    let cameraMessageeToInCall = "TO answer calls, Hipponeeds access to your iPhone's camera. Tap setting and turn on camera."
    
    func checkPermission() -> MicAndCameraPermissionResponse {
        
        var message: String
        var mark: Bool
        
        switch (callType , premissionType) {
        case (.in , .mic):
            mark = isRecordPermissionDenied
            message = micMessageToInCall
        case (.in , .camera):
            mark = isCameraPermissionDenied
            message = cameraMessageeToInCall
        case (.in , .both):
            mark = isRecordPermissionDenied
            if mark {
                message = micMessageToInCall
            }else {
                mark = isCameraPermissionDenied
                message = cameraMessageeToInCall
            }
        case (.out , .mic):
            mark = isRecordPermissionDenied
            message = micMessageToInOutCall
        case (.out , .camera):
            mark = isCameraPermissionDenied
            message = cameraMessageToOutCall
        case (.out , .both):
            mark = isRecordPermissionDenied
            if mark {
                message = micMessageToInOutCall
            }else {
                mark = isCameraPermissionDenied
                message = cameraMessageToOutCall
            }
        }
        return MicAndCameraPermissionResponse(isDenied: mark, message: message)
    }
    
    private var isRecordPermissionDenied: Bool {
        get {
            #if swift(<4.2)
            return AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.denied
            #else
            return AVAudioSession.sharedInstance().recordPermission == AVAudioSession.RecordPermission.denied
            #endif
        }
    }
    
    private  var isCameraPermissionDenied: Bool {
        get {
            return AVCaptureDevice.authorizationStatus(for: .video) == AVAuthorizationStatus.denied
        }
    }
    
    func showSettingAlert(for response: MicAndCameraPermissionResponse) {
        let alertController = UIAlertController (title: "", message: response.message , preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            #if swift(>=4.2)
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            #else
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            #endif
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let lastViewController = PermissionManager.getLastVisibleController()
        lastViewController?.present(alertController, animated: true, completion: nil)
    }
    class func getLastVisibleController(ofParent parent: UIViewController? = nil) -> UIViewController? {
        if let vc = parent {
            #if swift(>=4.2)
                let childVC = vc.children.first
            #else
                let childVC = vc.childViewControllers.first
            #endif
            
            
            if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
                return getLastVisibleController(ofParent: selected)
            } else if let nav = vc as? UINavigationController, let top = nav.topViewController {
                return getLastVisibleController(ofParent: top)
            } else if let presented = vc.presentedViewController {
                return getLastVisibleController(ofParent: presented)
            } else if let parsedChildVC = childVC {
                return getLastVisibleController(ofParent: parsedChildVC)
            } else {
                return vc
            }
        } else {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                return getLastVisibleController(ofParent: rootVC)
            } else {
                return nil
            }
        }
    }
    
    
    class func isShowLocalNotificationForAudioCall() -> Bool {
        let state =  UIApplication.shared.applicationState
        #if swift(>=4.2)
        let recordPermission =  AVAudioSession.sharedInstance().recordPermission
        #else
        let recordPermission =  AVAudioSession.sharedInstance().recordPermission()
        #endif
        
        if recordPermission == .granted {
            return false
        }else if state == .active {
            return false
        }else {
            return true
        }
    }
    
}
