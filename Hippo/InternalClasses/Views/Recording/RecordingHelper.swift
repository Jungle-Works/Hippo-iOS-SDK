//
//  RecordingHelper.swift
//  Hippo
//
//  Created by Arohi Magotra on 17/06/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//



import AVFoundation

protocol RecordingHelperDelegate : AnyObject{
    func recordingFinished(url: URL)
    /// Called instead of `recordingFinished` when the captured audio is shorter
    /// than `RecordingHelper.minimumDuration`.
    func recordingTooShort()
}

extension RecordingHelperDelegate {
    func recordingTooShort() {}
}


final
class RecordingHelper: UIView, AVAudioRecorderDelegate {
    
    //MARK:- Variables
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    weak var delegate: RecordingHelperDelegate?

    /// Audio shorter than this is rejected instead of being sent.
    static let minimumDuration: TimeInterval = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                       
                    } else {
                        // failed to record
                    }
                }
            }
        } catch {
            // failed to record
        }
    }
    

    
    /// Returns `false` if the session or recorder could not be started, so the
    /// caller can avoid showing a recording UI with nothing behind it.
    @discardableResult
    func startRecording() -> Bool {
        // Nothing else calls setupView(), so configure the session here - without
        // `.playAndRecord` active, AVAudioRecorder captures nothing on device.
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            finishRecording(success: false)
            return false
        }

        let audioFilename = getFileURL()

        let settings = [
            AVFormatIDKey:kAudioFormatMPEG4AAC
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            return true
        } catch {
            finishRecording(success: false)
            return false
        }
    }
    
    func finishRecording(success: Bool) {
        guard let recorder = audioRecorder else {
            return
        }

        // `currentTime` reads the length recorded so far — must be read before stop().
        let recordedDuration = recorder.currentTime
        recorder.stop()
        audioRecorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        guard success else {
            // recording cancelled / failed
            return
        }

        if recordedDuration >= RecordingHelper.minimumDuration {
            delegate?.recordingFinished(url: recorder.url)
        } else {
            delegate?.recordingTooShort()
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("AUD_\(Date().timeIntervalSince1970).aac")
        return path as URL
    }
    
    //MARK: Delegates
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        HippoConfig.shared.log.debug(("Error while recording audio \(error!.localizedDescription)"), level: .error)
    }
    
    
}
