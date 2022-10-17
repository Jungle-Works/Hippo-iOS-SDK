//
//  AudioPlayer.swift
//  iRecordView
//
//  Created by Devlomi on 8/19/19.
//  Copyright © 2019 Devlomi. All rights reserved.
//

import AVKit


enum AudioPlayerSounds {
    case start, end, error
}

class AudioPlayer: NSObject {

    private var player: AVAudioPlayer!
    
    var didFinishPlaying: ((Bool) -> Void)?

    override init() {
        player = AVAudioPlayer()
    }

    public func playAudioFile(soundType: AudioPlayerSounds) {
        didFinishPlaying = nil
        
        let bundle = FuguFlowManager.bundle
        
        guard let url = bundle?.url(forResource: getPathByType(soundType: soundType), withExtension: "wav") else{
            HippoConfig.shared.log.debug("error getting Sound URL", level: .error)
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            player.delegate = self
            player.prepareToPlay()
            player.play()
        } catch (let error) {
            HippoConfig.shared.log.debug(("could not play audio file!", error), level: .error)

        }

    }

    private func getPathByType(soundType: AudioPlayerSounds) -> String {
        switch soundType {
        case .start:
            return "record_start"
        case .end:
            return "record_finished"
        case .error:
            return "record_error"


        }
    }

}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        didFinishPlaying?(flag)
        didFinishPlaying = nil
    }
}
