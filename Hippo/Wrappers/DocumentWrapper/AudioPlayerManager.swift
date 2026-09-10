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


protocol AudioPlayerManagerDelegate: AnyObject {
    func timer(_ player: AVAudioPlayer)
    func playerEnded(_ player: AVAudioPlayer)
    func playbackFailed()
}

extension AudioPlayerManagerDelegate {
    func playbackFailed() {}
}
class AudioPlayerManager: NSObject {

    static var shared = AudioPlayerManager()
    var audioPlayer: AVAudioPlayer?
    var timer: Timer? = nil
    weak var delegate: AudioPlayerManagerDelegate?
    var tag: String = ""

    override init() {
        super.init()
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
    /// Puts the process-wide audio session into a state where playback is actually
    /// audible, and must run before every `AVAudioPlayer.play()` here.
    ///
    /// `AVAudioSession` is shared by the whole app and keeps whatever category was
    /// last set for the lifetime of the process. `RecordingHelper.startRecording()`
    /// leaves it on `.playAndRecord` and then calls `setActive(false)` when the
    /// recording finishes; a Hippo call leaves it on `.playAndRecord`/`.videoChat`.
    /// `.playAndRecord` routes output to the receiver (earpiece) unless the speaker
    /// is explicitly requested, so playing a voice note straight afterwards runs the
    /// player - and the progress timer - with nothing coming out of the speaker.
    /// Killing the app "fixed" it only because a fresh process starts on the default
    /// `.soloAmbient` category again.
    ///
    /// `.playback` is the right category here: it routes to the speaker on its own
    /// and, unlike `.playAndRecord`, does not need microphone permission - incoming
    /// voice notes have to play for users who never granted the mic.
    private func activatePlaybackSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            // Better to attempt playback on the existing category than to bail out.
            HippoConfig.shared.log.debug(("could not activate playback audio session", error), level: .error)
        }
    }

    func play() {
        guard audioPlayer != nil else {
            startNewPlayer()
            return
        }
        activatePlaybackSession()
        audioPlayer?.play()
        startTimer()
    }
    func stop() {
        guard audioPlayer != nil else {
            return
        }
        audioPlayer?.stop()
    }

    /// Pauses playback in place. Distinct from `stop()`: `AVAudioPlayer.pause()` is the
    /// lighter-weight, faster-to-resume call, and this method exists so call sites reading
    /// "pause the play/pause button" find a method that says exactly that.
    func pause() {
        audioPlayer?.pause()
    }

    /// Moves playback to `time`, clamped to the player's own bounds. No-op if no player is
    /// loaded yet.
    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = max(0, min(time, player.duration))
    }

    var currentTime: TimeInterval {
        audioPlayer?.currentTime ?? 0
    }

    var duration: TimeInterval {
        audioPlayer?.duration ?? 0
    }

    /// True once a player exists and isn't currently playing — covers both "paused mid-track"
    /// and "stopped/ended", which is the best distinction available without tracking extra
    /// state of our own on top of what AVAudioPlayer already reports.
    var isPaused: Bool {
        audioPlayer != nil && audioPlayer?.isPlaying == false
    }

    func startNewPlayer() {
        guard let localPathString = DownloadManager.shared.getLocalPathOf(url: tag),
            let url = URL(string: localPathString) else {
                delegate?.playbackFailed()
                return
        }
        guard let player = AudioPlayerManager.makePlayer(for: url) else {
            delegate?.playbackFailed()
            return
        }
        activatePlaybackSession()
        audioPlayer = player
        audioPlayer?.delegate = self
        audioPlayer?.play()
        startTimer()
    }

    /// `AVAudioPlayer(contentsOf:)` alone infers the format from the file extension,
    /// which fails for cached audio with a missing/misleading extension and for raw
    /// ADTS `.aac` (recorded by our own RecordingHelper, and common from other
    /// clients). Retry with explicit `fileTypeHint`s — m4a, ADTS aac, then mp3 —
    /// before giving up.
    static func makePlayer(for url: URL) -> AVAudioPlayer? {
        if let player = try? AVAudioPlayer(contentsOf: url) {
            return player
        }
        let hints: [String] = [
            AVFileType.m4a.rawValue,        // AAC in an MP4 container
            "public.aac-audio",             // raw ADTS .aac (AVFileType has no constant)
            AVFileType.mp3.rawValue,
            AVFileType.wav.rawValue,
            AVFileType.caf.rawValue
        ]
        for hint in hints {
            if let player = try? AVAudioPlayer(contentsOf: url, fileTypeHint: hint) {
                return player
            }
        }
        return nil
    }
    func startTimer() {
        disableTimer()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.timerCall()
            }
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

extension AudioPlayerManager: AVAudioPlayerDelegate {
    /// Reaching the end of the file on its own was previously invisible outside the polling
    /// timer, and the timer's own callback never re-checks the play/pause button's icon (only
    /// `playerEnded` does, via `updateUI()`). Without this, the button stayed on "pause" forever
    /// after a track finished naturally.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        disableTimer()
        delegate?.playerEnded(player)
    }
}


