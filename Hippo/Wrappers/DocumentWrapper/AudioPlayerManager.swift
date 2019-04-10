//
//  AudioPlayerManager.swift
//  Fugu
//
//  Created by Vishal on 10/01/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation
import UIKit
import NotificationCenter
import AVFoundation


protocol AudioPlayerManagerDelegate: class {
    func timer(_ player: AVAudioPlayer)
    func playerEnded(_ player: AVAudioPlayer)
}
class AudioPlayerManager {
    
    static var shared = AudioPlayerManager()
    var audioPlayer: AVAudioPlayer?
    var timer: Timer? = nil
    weak var delegate: AudioPlayerManagerDelegate?
    var tag: String = ""
    
    init() {
        addObserver()
    }
    func addObserver() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(AudioPlayerManager.shared.updateStatusForDelegate), name: .ConversationScreenDisappear, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AudioPlayerManager.appMovedToBackground), name: HippoVariable.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        guard audioPlayer != nil else {
            return
        }
        audioPlayer?.stop()
        delegate?.playerEnded(audioPlayer!)
    }
    
    @objc func updateStatusForDelegate() {
        guard audioPlayer != nil else {
            return
        }
        
        disableTimer()
        audioPlayer?.stop()
        audioPlayer?.isMeteringEnabled = true
        delegate?.playerEnded(audioPlayer!)
    }
    func play() {
        guard audioPlayer != nil else {
            startNewPlayer()
            return
        }
        audioPlayer?.play()
        startTimer()
    }
    func stop() {
        guard audioPlayer != nil else {
            return
        }
        audioPlayer?.stop()
    }
    
    func startNewPlayer() {
        guard let localPathString = DownloadManager.shared.getLocalPathOf(url: tag),
            let url = URL(string: localPathString) else {
                return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            startTimer()
        } catch  {
            
        }
    }
    func startTimer() {
        disableTimer()
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerCall), userInfo: nil, repeats: true)
        }
    }
    func disableTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerCall() {
        guard audioPlayer != nil else {
            return
        }
        delegate?.timer(self.audioPlayer!)
        if !audioPlayer!.isPlaying {
            disableTimer()
        }
    }
    
    class func getNewObject(with tag: String) -> AudioPlayerManager? {
        if tag == AudioPlayerManager.shared.tag {
            return nil
        }
        AudioPlayerManager.shared.updateStatusForDelegate()
        let newInstance = AudioPlayerManager()
        newInstance.tag = tag
        return newInstance
    }
}


