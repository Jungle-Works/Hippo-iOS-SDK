//
//  SoundPlayer.swift
//  HippoChat
//
//  Created by Vishal on 18/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import Foundation
import AVKit

class SoundPlayer {
    static func messageSentSucessfully() {
        let sound = HippoAudio.messageSent
        guard sound.enabled else {
            return
        }
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(sound.soundID)
        }
    }
}
