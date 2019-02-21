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

#if canImport(HippoCallClient)
import HippoCallClient
#endif

protocol AudioCallViewDelegate: class {
    func muteAudio(isMuted: Bool)
    func switchToSpeaker(isSwitchedToSpeaker: Bool, completion: @escaping (Bool) -> Void)
    func disconnectCallButtonPressed()
}

#if canImport(HippoCallClient)
@available(iOS 10.0, *)
class AudioCallView: UIView {
    
    // MARK: - Properties
    weak var delegate: AudioCallViewDelegate?
    private var timer: Timer?
    
    private var timeElapsedSinceCallConnected: TimeInterval = 0
    
    private let pulseLayer = CallPulsator()
    private var player: AVAudioPlayer?
    
    // MARK: - IBOutlets
    @IBOutlet weak var peerImageView: UIImageView!
    @IBOutlet weak var peerNameLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var switchToSpeakerButton: UIButton!
    @IBOutlet weak var pulseView: UIView!
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pulseView.isHidden = true
    }
    
    // MARK: - IBAction
    @IBAction func switchToSpeakerButtonPressed(_ sender: UIButton) {
        
        let switchToSpeaker = !sender.isSelected
        sender.isEnabled = false
        delegate?.switchToSpeaker(isSwitchedToSpeaker: switchToSpeaker, completion: { (success) in
            sender.isEnabled = true
            if success {
                sender.isSelected = switchToSpeaker
            }
        })
    }
    
    @IBAction func muteButtonPressed(_ sender: UIButton) {
        let isCurrentlyMuted = sender.isSelected
        
        sender.isEnabled = false
        delegate?.muteAudio(isMuted: !isCurrentlyMuted)
        sender.isSelected = !isCurrentlyMuted
    }
    
    @IBAction func disconnectButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        delegate?.disconnectCallButtonPressed()
    }
    
    // MARK: - Methods
    func setUIForOutgoingCall() {
        timeLabel.isHidden = false
        timeLabel.text = "Ringing..."
        addPulseAroundUserImage()
        playSound(soundName: "ringing", numberOfLoops: Int.max)
    }
    
    func callConnected() {
        startTimer()
        stopPulse()
        stopPlaying()
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
        
        timeLabel.text = timePassed
    }
    
    func callDisconnected() {
        stopTimer()
        stopPlaying()
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
        // Set Image in peerImageView for string peer.image
        
        peerNameLabel.text = peer.name
    }
    
    func addPulseAroundUserImage() {
        pulseView.isHidden = false
        pulseLayer.backgroundColor = UIColor.blue.cgColor
        pulseLayer.position = CGPoint(x: 45, y: 45)
        pulseLayer.radius = 90
        pulseLayer.instanceCount = 3
        pulseLayer.fromValueForRadius = 0.5
        pulseView.layer.addSublayer(pulseLayer)
        pulseLayer.start()
    }
    
    func stopPulse() {
        pulseView.isHidden = true
        pulseLayer.stop()
    }
    
    func playSound(soundName: String, numberOfLoops: Int) {
        guard let url =  Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            #if swift(>=4.0)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            #else
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            #endif
            
            guard let player = player else { return }
            
            if AVAudioSession.sharedInstance().outputVolume < 0.4 {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
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
    
}
#endif
