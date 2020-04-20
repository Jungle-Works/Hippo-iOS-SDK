//
//  AudioCallView.swift
//  OfficeChat
//
//  Created by Asim on 18/10/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import Hippo
import AVKit

#if canImport(HippoCallClient)
import HippoCallClient
#endif

//protocol AudioCallViewDelegate: class {
//    func muteAudio(isMuted: Bool)
//    func switchToSpeaker(isSwitchedToSpeaker: Bool, completion: @escaping (Bool) -> Void)
//    func disconnectCallButtonPressed()
//}

//#if canImport(HippoCallClient)
//@available(iOS 10.0, *)
//class AudioCallView: UIView {
//
//    // MARK: - Properties
//    weak var delegate: AudioCallViewDelegate?
//    private var timer: Timer?
//
//    private var timeElapsedSinceCallConnected: TimeInterval = 0
//
//    private let pulseLayer = CallPulsator()
//    private var player: AVAudioPlayer?
//
//    // MARK: - IBOutlets
//    @IBOutlet weak var peerImageView: UIImageView!
//    @IBOutlet weak var peerNameLabel: UILabel!
//    @IBOutlet weak var muteButton: UIButton!
//    @IBOutlet weak var disconnectButton: UIButton!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var switchToSpeakerButton: UIButton!
//    @IBOutlet weak var pulseView: UIView!
//
//    // MARK: - View Life Cycle
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        pulseView.isHidden = true
//    }
//
//    // MARK: - IBAction
//    @IBAction func switchToSpeakerButtonPressed(_ sender: UIButton) {
//
//        let switchToSpeaker = !sender.isSelected
//        sender.isEnabled = false
//        delegate?.switchToSpeaker(isSwitchedToSpeaker: switchToSpeaker, completion: { (success) in
//            sender.isEnabled = true
//            if success {
//                sender.isSelected = switchToSpeaker
//            }
//        })
//    }
//
//    @IBAction func muteButtonPressed(_ sender: UIButton) {
//        let isCurrentlyMuted = sender.isSelected
//
//        sender.isEnabled = false
//        delegate?.muteAudio(isMuted: !isCurrentlyMuted)
//        sender.isSelected = !isCurrentlyMuted
//    }
//
//    @IBAction func disconnectButtonPressed(_ sender: UIButton) {
//        sender.isEnabled = false
//        delegate?.disconnectCallButtonPressed()
//    }
//
//
//
//    // MARK: - Methods
//    func setUIForOutgoingCall() {
//        timeLabel.isHidden = false
//        timeLabel.text = "Ringing..."
//        addPulseAroundUserImage()
//        playSound(soundName: "ringing", numberOfLoops: Int.max)
//    }
//    func setUIForConnectingCall() {
//        timeLabel.isHidden = false
//        timeLabel.text = "Connecting..."
//        addPulseAroundUserImage()
//    }
//
//    func callConnected() {
//        startTimer()
//        stopPulse()
//        stopPlaying()
//    }
//
//    func setUIForIncomingCall() {
//        timeLabel.isHidden = false
//        timeLabel.text = "Incoming"
//        addPulseAroundUserImage()
//    }
//
//    private func startTimer() {
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
//            self?.timeElapsedSinceCallConnected += 1
//            self?.setTimerLabel()
//        })
//    }
//
//    private func setTimerLabel() {
//        let minutesPassed = Int(timeElapsedSinceCallConnected / 60)
//        let secondsPassed = Int(timeElapsedSinceCallConnected) % 60
//
//        let seconsInString = secondsPassed < 10 ? ("0" + secondsPassed.description) : secondsPassed.description
//        let minutesInString = minutesPassed < 10 ? ("0" + minutesPassed.description) : minutesPassed.description
//
//        let timePassed = minutesInString + ":" + seconsInString
//
//        timeLabel.text = timePassed
//    }
//
//    func callDisconnected() {
//        stopTimer()
//        stopPlaying()
//    }
//
//    fileprivate func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//
//    func audioMuted(_ isMuted: Bool) {
//        muteButton.isSelected = isMuted
//        muteButton.isEnabled = true
//    }
//
//    func setUIWith(peer: CallerInfo) {
//        // Set Image in peerImageView for string peer.image
//
//        peerNameLabel.text = peer.name
//    }
//
//    func addPulseAroundUserImage() {
//        pulseView.isHidden = false
//        pulseLayer.backgroundColor = UIColor.blue.cgColor
//        pulseLayer.position = CGPoint(x: 45, y: 45)
//        pulseLayer.radius = 90
//        pulseLayer.instanceCount = 3
//        pulseLayer.fromValueForRadius = 0.5
//        pulseView.layer.addSublayer(pulseLayer)
//        pulseLayer.start()
//    }
//
//    func stopPulse() {
//        pulseView.isHidden = true
//        pulseLayer.stop()
//    }
//
//    func playSound(soundName: String, numberOfLoops: Int) {
//        guard let url =  Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
//
//        do {
//
//            #if swift(>=5.0)
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
//            #elseif swift(>=4.2)
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowBluetooth)
//            #else
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            #endif
//
//            try AVAudioSession.sharedInstance().setActive(true)
//
//
//            #if swift(>=4.0)
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//            #else
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
//            #endif
//
//            guard let player = player else { return }
//
//            if AVAudioSession.sharedInstance().outputVolume < 0.4 {
//                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//            }
//
//            player.numberOfLoops = numberOfLoops
//            player.play()
//
//
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
//
//    func stopPlaying() {
//        player?.stop()
//        player = nil
//    }
//
//
//    // MARK: - Type Methods
//    static func get() -> AudioCallView {
//        let view = Bundle.main.loadNibNamed("AudioCallView", owner: nil, options: nil)?.first as! AudioCallView
//        return view
//    }
//
//}






protocol AudioCallViewDelegate: class {
    func muteAudio(isMuted: Bool)
    func switchToSpeaker(isSwitchedToSpeaker: Bool, completion: @escaping (Bool) -> Void)
    func disconnectCallButtonPressed()
    func pipMode(for mark:Bool)
}

class AudioCallView: UIView {
    
    // MARK: - Properties
    weak var delegate: AudioCallViewDelegate?
    private var timer: Timer?
    
    private var timeElapsedSinceCallConnected: TimeInterval = 0
    
    @IBOutlet weak var disAndSpeakerConstant: NSLayoutConstraint!
    @IBOutlet weak var disbottomConstant: NSLayoutConstraint!
    private let pulseLayer = Pulsator()
    private var player: AVAudioPlayer?
    private var previousFrame: CGRect = .zero
    // MARK: - IBOutlets
    @IBOutlet weak var peerImageView: UIImageView!
    @IBOutlet weak var peerNameLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var switchToSpeakerButton: UIButton!
    @IBOutlet weak var pulseView: UIView!
    
    var PIPbarView: UIView?
    var PIPMessageLabel: UILabel?
    var barTap: UITapGestureRecognizer?
    private var isReconncting: Bool = false
    private var  gradientLayer: CAGradientLayer?
    
    var showReconnecting: Bool {
        set {
            isReconncting = newValue
        }
        get {
            return isReconncting
        }
    }
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pulseView.isHidden = true
        PIPbarView?.isHidden = true
        addLayer()
        speakerAndMuteButtonSetup()
        updateUI()
    }
    
    func addLayer() {
        gradientLayer =  CAGradientLayer()
        let startColor = UIColor.init(hex: 0x516C77).cgColor
        let endColor =  UIColor.init(hex: 0x804F48).cgColor// light red
        gradientLayer?.colors = [endColor ,startColor]
        gradientLayer?.locations = [0.0,1.0]
        gradientLayer?.frame = (UIApplication.shared.keyWindow?.frame)!
        let startPoint = CGPoint(x: 0.0, y: 1.0)
        let endPoint = CGPoint(x: 0.20, y: 0.5)
        gradientLayer?.startPoint = startPoint
        gradientLayer?.endPoint =  endPoint
        self.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    
    
    func updateUI() {
        let width = UIApplication.shared.keyWindow?.frame.width
        
        if let someWidth  = width, someWidth <= 320 {
            disbottomConstant.constant = 32
            disAndSpeakerConstant.constant = 32
            layoutIfNeeded()
        }
        
    }
    
    
    // MARK: - IBAction
    @IBAction func switchToSpeakerButtonPressed(_ sender: UIButton) {
        
        if #available(iOS 11.0, *), isMultiAvailableInputs() {
            let routePickerView = AVRoutePickerView()
            self.addSubview(routePickerView)
            routePickerView.isHidden = true
            if let routePickerButton = routePickerView.subviews.first(where: { $0 is UIButton }) as? UIButton {
                routePickerButton.sendActions(for: .touchUpInside)
            }
        } else {
            let switchToSpeaker = !sender.isSelected
            //sender.isEnabled = false
            delegate?.switchToSpeaker(isSwitchedToSpeaker: switchToSpeaker, completion: {[weak self] (success) in
                // sender.isEnabled = true
                if success {
                    sender.isSelected = switchToSpeaker
                    let type = switchToSpeaker ? AudioOutputType.speaker : AudioOutputType.phone
                    self?.speakerSetup(for: type)
                }
            })
        }
    }
    
    
    func isMultiAvailableInputs()-> Bool {
        
        let availableInputs = AVAudioSession.sharedInstance().availableInputs
        
        if let some = availableInputs, some.count > 1 {
            return true
        }
        return false
        
    }
    
    @IBAction func muteButtonPressed(_ sender: UIButton) {
        let isCurrentlyMuted = sender.isSelected
        sender.isEnabled = false
        delegate?.muteAudio(isMuted: !isCurrentlyMuted)
        sender.isSelected = !isCurrentlyMuted
        muteSetup(for: !isCurrentlyMuted)
    }
    
    func muteSetup(for mark:Bool) {
        if mark {
            muteButton.backgroundColor = .white
            let img = UIImage(named: "mute", in: nil, compatibleWith: nil)
            let mute = img?.withRenderingMode(.alwaysTemplate)
            muteButton.tintColor = UIColor.black
            muteButton.setImage(mute, for: .normal)
        }else {
            muteButton.backgroundColor = UIColor.init(hex: 0x4A91A4).withAlphaComponent(0.6)
            let img = UIImage(named: "mute", in: nil, compatibleWith: nil)
            let mute = img?.withRenderingMode(.alwaysTemplate)
            muteButton.tintColor = UIColor.white
            muteButton.setImage(mute, for: .normal)
        }
    }
    
    func speakerSetup(for type: AudioOutputType) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
            switch type {
            case .phone:
                self.switchToSpeakerButton.backgroundColor = UIColor.init(hex: 0x4A91A4).withAlphaComponent(0.6)
                let img = UIImage(named: "speaker", in: nil, compatibleWith: nil)
                let mute = img?.withRenderingMode(.alwaysTemplate)
                self.switchToSpeakerButton.tintColor = UIColor.white
                self.switchToSpeakerButton.setImage(mute, for: .normal)
            case .speaker:
                self.switchToSpeakerButton.backgroundColor = .white
                let img = UIImage(named: "speaker", in: nil, compatibleWith: nil)
                let mute = img?.withRenderingMode(.alwaysTemplate)
                self.switchToSpeakerButton.tintColor = UIColor.black
                self.switchToSpeakerButton.setImage(mute, for: .normal)
            case .headphone:
                
                self.switchToSpeakerButton.backgroundColor = UIColor.init(hex: 0x4A91A4).withAlphaComponent(0.6)
                let img = UIImage(named: "bluetoothSpeaker", in: nil, compatibleWith: nil)
                let mute = img?.withRenderingMode(.alwaysTemplate)
                self.switchToSpeakerButton.tintColor = UIColor.white
                self.switchToSpeakerButton.setImage(mute, for: .normal)
                
            }
        })
    }
    
    @IBAction func disconnectButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
//        if sender.tag == 11 {
//            CallClient.shared.isCallSwitch = true
//        }else {
//            CallClient.shared.isCallSwitch = false
//        }
//        self.isHidden = true
        delegate?.disconnectCallButtonPressed()
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        showBarView()
    }
    
    // MARK: - Methods
    func setUIForOutgoingCall() {
        timeLabel.isHidden = false
        timeLabel.text = "Calling..."
        addPulseAroundUserImage()
        playSound(soundName: "ringing", numberOfLoops: Int.max)
    }
    func setUIForConnectingCall() {
        timeLabel.isHidden = false
        timeLabel.text = "Connecting..."
        addPulseAroundUserImage()
        playSound(soundName: "ringing", numberOfLoops: Int.max)
    }
    
    func callConnected() {
        startTimer()
        stopPulse()
        stopPlaying()
//        CallClient.shared.wasCallConnected = true
        
        let manger = PermissionManager(with: .mic, call: .in)
        let response = manger.checkPermission()
        if response.isDenied {
//            CallClient.shared.wasCallConnected = false
            manger.showSettingAlert(for: response)
            let sender = UIButton()
            disconnectButtonPressed(sender)
        }
    }
    
    func setupRingingText(){
        timeLabel.text = "Ringing..."
    }
    
    func setUIForIncomingCall() {
        timeLabel.isHidden = false
        timeLabel.text = "Incoming"
        addPulseAroundUserImage()
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.timeElapsedSinceCallConnected += 1
            self?.setTimerLabel()
        })
    }
    
    private func setTimerLabel() {
        let minutesPassed = Int(timeElapsedSinceCallConnected / 60)
        let secondsPassed = Int(timeElapsedSinceCallConnected) % 60
        
        let seconsInString = secondsPassed < 10 ? ("0" + secondsPassed.description) : secondsPassed.description
        let minutesInString = minutesPassed < 10 ? ("0" + minutesPassed.description) : minutesPassed.description
        
        let timePassed = minutesInString + ":" + seconsInString
        
        if isReconncting {
            timeLabel.text = "Reconnecting to " + (peerNameLabel.text ?? "")
        }else {
            timeLabel.text = timePassed
        }
    }
    
    func callDisconnected() {
        removePIPView()
        self.stopTimer()
        self.stopPlaying()
    }
    
    fileprivate func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func audioMuted(_ isMuted: Bool) {
        muteButton.isSelected = isMuted
        muteButton.isEnabled = true
    }
    
    func setUIWith(peer: CallerInfo) {
        //TODO: Set peer image
//        let url = URL(string: peer.image)
//        peerImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "name01"))
        peerNameLabel.text = peer.name
    }
    
    func addPulseAroundUserImage() {
        pulseView.isHidden = false
        pulseLayer.backgroundColor = UIColor.blue.cgColor
        pulseLayer.position = CGPoint(x: 60, y: 60)
        pulseLayer.radius = 120
        pulseLayer.instanceCount = 3
        pulseLayer.fromValueForRadius = 0.5
        pulseView.layer.addSublayer(pulseLayer)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
           self.pulseLayer.start()
        })
    }
    
    func stopPulse() {
        pulseView.isHidden = true
        pulseLayer.stop()
    }
    
    func playSound(soundName: String, numberOfLoops: Int) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        
        do {
            #if swift(>=5.0)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [.allowBluetooth,.allowBluetoothA2DP,.mixWithOthers,.allowAirPlay])
            #elseif swift(>=4.2)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowBluetooth)
            #else
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            #endif
            try AVAudioSession.sharedInstance().setActive(true)
            if #available(iOS 11.0, *) {
                setSpeaker()
            }
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.numberOfLoops = numberOfLoops
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopPlaying() {
        player?.stop()
        player = nil
    }
    
    // MARK: - Type Methods
    static func get() -> AudioCallView {
        let view = Bundle.main.loadNibNamed("AudioCallView", owner: nil, options: nil)?.first as! AudioCallView
        return view
    }
    
    deinit {
        if #available(iOS 11.0, *) {
            removeNotification()
        }
    }
}


extension AudioCallView {
    func showBarView() {
        previousFrame = self.frame
        var upadtedFrame = previousFrame
        let topPadding = UIApplication.shared.statusBarFrame.height
        
        upadtedFrame.size.height =  topPadding
        self.frame = upadtedFrame
        self.gradientLayer?.frame = upadtedFrame
        self.layoutIfNeeded()
        for view in self.subviews {
            view.isHidden = true
        }
        delegate?.pipMode(for: true)
        setupTapBar()
    }
    
    func showMessage() {
        PIPMessageLabel?.alpha = 0.2
        if let someLabel = PIPMessageLabel {
            UIView.animate(withDuration: 1.5, animations: {
                someLabel.alpha = 1
            }) { (mark) in
                self.showMessage()
            }
        }
    }
    
    func setupTapBar() {
//        let topPadding = UIApplication.shared.statusBarFrame.height
//        PIPbarView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: topPadding + 10))
//        barTap = UITapGestureRecognizer(target: self, action: #selector(tapOnPIPView))
//        PIPbarView?.addGestureRecognizer(barTap!)
//        PIPbarView?.isUserInteractionEnabled = true
//        PIPbarView?.backgroundColor =  UIColor.hexStringToUIColor (hex:"#4AD862", alpha:1.0)
//        PIPMessageLabel = UILabel(frame: CGRect(x: 0, y: (PIPbarView?.frame.height)! - 20, width: self.frame.size.width, height: 16))
//        PIPMessageLabel?.text = "Touch to return to call"
//        PIPMessageLabel?.textColor = .white
//        PIPMessageLabel?.textAlignment = .center
//        PIPMessageLabel?.font = PIPMessageLabel?.font.withSize(14)
//        PIPbarView?.addSubview(PIPMessageLabel!)
//        UIApplication.shared.statusBarView?.addSubview(PIPbarView!)
//        showMessage()
    }
    
    @objc func tapOnPIPView() {
        delegate?.pipMode(for: false)
        
        self.frame = previousFrame
        self.gradientLayer?.frame = (UIApplication.shared.keyWindow?.frame)!
        for view in subviews {
            view.isHidden = false
        }
        self.layoutIfNeeded()
        
        removePIPView()
    }
    
    func removePIPView() {
        PIPbarView?.isHidden = true
        PIPMessageLabel?.removeFromSuperview()
        PIPMessageLabel = nil
        PIPbarView?.removeFromSuperview()
        PIPbarView = nil
    }
}

extension UIApplication {
    /// Returns the status bar UIView
    var statusBarView: UIView? {
        let view  =  value(forKey: "statusBar") as? UIView
        return view
    }
}

extension AudioCallView {
    func speakerAndMuteButtonSetup() {
        muteButton.layer.cornerRadius  = muteButton.frame.height/2
        muteButton.layer.masksToBounds = true
        muteButton.backgroundColor = UIColor.init(hex: 0x4A91A4).withAlphaComponent(0.6)
        switchToSpeakerButton.layer.cornerRadius = switchToSpeakerButton.frame.height / 2
        switchToSpeakerButton.layer.masksToBounds = true
        switchToSpeakerButton.backgroundColor = UIColor.init(hex: 0x4A91A4).withAlphaComponent(0.6)
        
    }
}

@available(iOS 11.0, *)
extension AudioCallView: AVRoutePickerViewDelegate {
    
    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        
    }
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        
    }
    
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        #if swift(>=4.2)
        notificationCenter.addObserver(self,selector: #selector(handleRouteChange),name: AVAudioSession.routeChangeNotification, object: nil)
        #else
        notificationCenter.addObserver(self,selector: #selector(handleRouteChange),name: .AVAudioSessionRouteChange, object: nil)
        #endif
    }
    
    @objc func handleRouteChange(notification: Notification) {
        //        Logger.shared.printVar(for: notification)
        //        Logger.shared.printVar(for: AVAudioSession.sharedInstance().currentRoute.inputs)
        //        Logger.shared.printVar(for: AVAudioSession.sharedInstance().currentRoute.outputs)
        setSpeaker()
    }
    
    
    func setSpeaker() {
        let output = AVAudioSession.sharedInstance().currentRoute.outputs.first
        if let someOutput =  output {
            let outType = someOutput.portType
            #if swift(>=4.2)
            switch outType {
            case AVAudioSession.Port.builtInSpeaker:
                speakerSetup(for: .speaker)
            case AVAudioSession.Port.builtInReceiver:
                speakerSetup(for: .phone)
            case AVAudioSession.Port.bluetoothHFP:
                speakerSetup(for: .headphone)
            default:
                speakerSetup(for: .phone)
            }
            #else
            switch outType {
            case AVAudioSessionPortBuiltInSpeaker:
                speakerSetup(for: .speaker)
            case AVAudioSessionPortBuiltInReceiver:
                speakerSetup(for: .phone)
            case AVAudioSessionPortBluetoothHFP:
                speakerSetup(for: .headphone)
            default:
                speakerSetup(for: .phone)
            }
            #endif
        } else {
            speakerSetup(for: .phone)
        }
    }
    
    func removeNotification() {
        let notificationCenter = NotificationCenter.default
        #if swift(>=4.2)
        notificationCenter.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        #else
        notificationCenter.removeObserver(self, name: .AVAudioSessionRouteChange, object: nil)
        #endif
    }
}


