//
//  RecordingHelper.swift
//  Hippo
//
//  Created by Arohi Magotra on 17/06/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//



import AVFoundation

protocol RecordingHelperDelegate : class{
    func recordingFinished(url: URL)
}


final
class RecordingHelper: UIView, AVAudioRecorderDelegate {
    
    //MARK:- Variables
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    weak var delegate: RecordingHelperDelegate?
    
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
            recordingSession.requestRecordPermission() { [unowned self] allowed in
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
    

    
    func startRecording() {
        let audioFilename = getFileURL()
        
        let settings = [
            AVFormatIDKey:kAudioFormatMPEG4AAC
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
           
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        if audioRecorder == nil {
            return
        }
        
        audioRecorder.stop()
        
        if success {
            delegate?.recordingFinished(url: audioRecorder.url)
            audioRecorder = nil
        } else {
            audioRecorder = nil
            // recording failed :(
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
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    
}
