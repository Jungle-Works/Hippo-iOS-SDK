//
//  WebRTCClient.swift
//  HippoCallClient
//
//  Created by Vishal on 31/08/18.
//  Copyright © 2018 Vishal All rights reserved.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: class {
    func sendOfferViaSignalling(json: [String: Any])
    func sendAnswerViaSignalling(json: [String: Any])
    func sendCandidateViaSignalling(json: [String: Any])
    
    func rtcConnectionDisconnected()
    func rtcConnectionRetry()
    func rtcConnecetd()
    
    func viewForRenderingLocalVideo() -> UIView?
    func viewForRenderingRemoteVideo() -> UIView?
}

class WebRTCClient: NSObject, RTCPeerConnectionDelegate {
    
    // MARK: - Properties
    fileprivate let factory: RTCPeerConnectionFactory
    fileprivate var peerConnection: RTCPeerConnection?
    
    weak var delegate: WebRTCClientDelegate?
    
    fileprivate var videoCapturer: RTCVideoCapturer?
    fileprivate var remoteStream: RTCMediaStream?
    fileprivate var localVideoTrack: RTCVideoTrack?
    
    fileprivate var localVideoRenderer: RTCVideoRenderer?
    fileprivate var remoteVideoRenderer: RTCVideoRenderer?
    
    fileprivate var localVideoAspectRatio: CGSize?
    fileprivate var remoteVideoAspectRatio: CGSize?
    fileprivate let defaultAspectRatio = CGSize(width: 3, height: 4)
    
    #if swift(>=4.2)
    fileprivate var currentAudioOveride = AVAudioSession.PortOverride.none
    #else
    fileprivate var currentAudioOveride = AVAudioSessionPortOverride.none
    #endif
    
    fileprivate var isUsingFrontCamera = true
    
    fileprivate var isVoiceOnlyCall: Bool = false
    
    lazy fileprivate var mediaConstrains: [String: String] = {
        var constraints = [
            kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue
        ]
        if !self.isVoiceOnlyCall {
            constraints[kRTCMediaConstraintsOfferToReceiveVideo] = kRTCMediaConstraintsValueTrue
        }
        return constraints
    }()
    
    // MARK: - Intializer
    init(delegate: WebRTCClientDelegate, credentials: CallClientCredential, isVoiceOnlyCall: Bool) {
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        self.factory = RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
        self.isVoiceOnlyCall = isVoiceOnlyCall
        
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        
        let config = RTCConfiguration()
        config.iceServers = credentials.getIceServers()
        config.iceTransportPolicy = .all
        config.bundlePolicy = .maxBundle
        config.rtcpMuxPolicy = .require
        
        // Unified plan is more superior than planB
        config.sdpSemantics = .planB
        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually
        self.delegate = delegate
        
        
        super.init()
        self.peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: self)
        createMediaSenders()
        if let localVideoView = self.delegate?.viewForRenderingLocalVideo() {
            renderLocalVideoIn(view: localVideoView)
        }
        
        RTCSetMinDebugLogLevel(.error)
    }
    
    func getFilePath() -> String {
        let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let imageUrlInCacheDirectory = cacheDirectoryURL.appendingPathComponent("rtcLogs")
        return imageUrlInCacheDirectory.path
    }
    
    // MARK: - Methods
    
    // MARK: Signal Handling
    
    func candidateReceivedFromSignalling(json: [String: Any]) {
        guard let candidate = RTCIceCandidate.fromJson(json) else {
            return
        }
        
        peerConnection?.add(candidate)
    }
    
    func sdpReceivedFromSignalling(json: [String: Any]) {
        guard let sessionDescription = RTCSessionDescription.fromJson(json) else {
            return
        }
        
        let newChangedOffer = peerConnection?.remoteDescription != nil
        
        peerConnection?.setRemoteDescription(sessionDescription) { [weak self] (error) in
            
            guard error == nil, let weakSelf = self else {
                print("Error in setting Remote Description -> \(error.debugDescription)")
                return
            }
            
            switch sessionDescription.type {
            case .answer, .prAnswer:
                
                if !weakSelf.isHeadphonePluggedIn() && self?.isVoiceOnlyCall == false {
                    self?.changeAudioRouteToSpeaker(true, completion: {_ in})
                }
            case .offer where newChangedOffer:
                if let localDescription = self?.peerConnection?.localDescription {
                    self?.delegate?.sendAnswerViaSignalling(json: localDescription.toJson())
                }
            case .offer:
                break
            }
        }
        
    }
    
    // MARK: Call
    func startNewCall(completion: @escaping (Bool) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains,
                                             optionalConstraints: nil)
        
        func sendOfferForSignaling(sdp: RTCSessionDescription) {
            let json = sdp.toJson()
            self.delegate?.sendOfferViaSignalling(json: json)
        }
        
        if let sdp = peerConnection?.localDescription {
            sendOfferForSignaling(sdp: sdp)
            return
        }
        
        self.peerConnection?.offer(for: constrains) { (sdp, error) in
            guard let sdp = sdp else {
                completion(false)
                return
            }
            
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { (error) in
                if error == nil {
                    sendOfferForSignaling(sdp: sdp)
                }
                completion(error == nil)
            })
        }
    }
    
    func incomingCallAnswered() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)
        
        if peerConnection?.localDescription != nil {
            print("Error: Already answered")
            return
        }
        
        peerConnection?.answer(for: constraints) { (answerSdp, error) in
            guard let answerSdp = answerSdp else {
                print(error.debugDescription)
                return
            }
            
            self.peerConnection?.setLocalDescription(answerSdp, completionHandler: { [weak self] (error) in
                guard error == nil else {
                    print("Error While Setting answer as Local Description: \(error.debugDescription)")
                    return
                }
                
                let answerJson = answerSdp.toJson()
                self?.delegate?.sendAnswerViaSignalling(json: answerJson)
                if self?.isHeadphonePluggedIn() == false && self?.isVoiceOnlyCall == false {
                    self?.changeAudioRouteToSpeaker(true, completion: {_ in})
                }
            })
        }
    }
    
    func endCall() {
        delegate = nil
        remoteStream = nil
        (videoCapturer as? RTCCameraVideoCapturer)?.stopCapture()
        videoCapturer = nil
        localVideoTrack = nil
        peerConnection?.close()
        peerConnection = nil
    }
    
    // MARK: In Call Setting Change Methods
    func changeAudioRouteToSpeaker(_ isSwitching: Bool, completion: @escaping (Bool) -> Void) {
        
        #if swift(>=4.2)
        let newOveride = isSwitching ? AVAudioSession.PortOverride.speaker : AVAudioSession.PortOverride.none
        #else
        let newOveride = isSwitching ? AVAudioSessionPortOverride.speaker : AVAudioSessionPortOverride.none
        #endif
        
        //        let newOveride = isSwitching ? AVAudioSessionPortOverride.speaker : AVAudioSessionPortOverride.none
        
        if currentAudioOveride == newOveride {
            completion(true)
            return
        }
        
        RTCDispatcher.dispatchAsync(on: .typeAudioSession) {
            let session = RTCAudioSession.sharedInstance()
            session.lockForConfiguration()
            do {
                try RTCAudioSession.sharedInstance().overrideOutputAudioPort(newOveride)
                self.currentAudioOveride = newOveride
                RTCDispatcher.dispatchAsync(on: .typeMain, block: {
                    completion(true)
                })
                
            } catch {
                print(error.localizedDescription)
                RTCDispatcher.dispatchAsync(on: .typeMain, block: {
                    completion(false)
                })
            }
            session.unlockForConfiguration()
        }
    }
    
    func muteAudio(completion: (Bool) -> Void) {
        guard let audioTrack = getCurrentAudioStream() else {
            completion(false)
            return
        }
        
        audioTrack.isEnabled = false
        completion(true)
    }
    
    func unmuteAudio(completion: (Bool) -> Void) {
        guard let audioTrack = getCurrentAudioStream() else {
            completion(false)
            return
        }
        
        audioTrack.isEnabled = true
        completion(true)
    }
    
    func startVideo() {
        let stream = getCurrentVideoStream()
        stream?.isEnabled = true
    }
    
    func pauseVideo() {
        let stream = getCurrentVideoStream()
        stream?.isEnabled = false
    }
    
    func switchCamera() {
        isUsingFrontCamera = !isUsingFrontCamera
        
        (videoCapturer as? RTCCameraVideoCapturer)?.stopCapture(completionHandler: { [weak self] in
            self?.startCaptureLocalVideo()
        })
    }
    
    func localAndRemoteViewSwitched() {
        guard
            let remoteView = delegate?.viewForRenderingRemoteVideo(),
            let localView = delegate?.viewForRenderingLocalVideo(),
            let remoteVideoRenderer = self.remoteVideoRenderer,
            let localVideoRenderer = self.localVideoRenderer else {
                return
        }
        
        removeVideoFrom(view: remoteView)
        removeVideoFrom(view: localView)
        
        embed(view: remoteVideoRenderer, in: remoteView, withAspectRatio: remoteVideoAspectRatio)
        embed(view: localVideoRenderer, in: localView, withAspectRatio: localVideoAspectRatio)
    }
    
    func frameOfLocalVideoContainerViewChanged() {
        guard let view = localVideoRenderer as? RTCEAGLVideoView else {
            return
        }
        
        guard let superView = delegate?.viewForRenderingLocalVideo() else {
            return
        }
        setRectOf(view: view, in: superView, withAspectRatio: localVideoAspectRatio ?? defaultAspectRatio)
    }
    
    func frameOfRemoteVideoContainerViewChanged() {
        guard let view = remoteVideoRenderer as? RTCEAGLVideoView else {
            return
        }
        guard let superView = delegate?.viewForRenderingRemoteVideo() else {
            return
        }
        setRectOf(view: view, in: superView, withAspectRatio: remoteVideoAspectRatio ?? defaultAspectRatio)
    }
    
    // MARK: Audio
    static func configureAudioSession() {
        
        let config = RTCAudioSessionConfiguration.webRTC()
        
        #if swift(>=4.2)
        config.category = AVAudioSession.Category.playAndRecord.rawValue
        config.mode = AVAudioSession.Mode.voiceChat.rawValue
        #else
        config.category = AVAudioSessionCategoryPlayAndRecord
        config.mode = AVAudioSessionModeVoiceChat
        #endif
        
        //        config.category = AVAudioSessionCategoryPlayAndRecord
        //        config.mode = AVAudioSessionModeVoiceChat
        if #available(iOS 10.0, *) {
            config.categoryOptions = [
                .allowBluetooth,
                .allowBluetoothA2DP,
                .interruptSpokenAudioAndMixWithOthers
            ]
        } else {
            config.categoryOptions = [
                .allowBluetooth,
                .interruptSpokenAudioAndMixWithOthers
            ]
        }
        RTCAudioSession.sharedInstance().useManualAudio = true
        RTCAudioSession.sharedInstance().isAudioEnabled = false
        
        do {
            RTCAudioSession.sharedInstance().lockForConfiguration()
            try RTCAudioSession.sharedInstance().setConfiguration(config)
            RTCAudioSession.sharedInstance().unlockForConfiguration()
        } catch {
            let errorMessage = (error as NSError).debugDescription
            print("Failed to configure audio session -> \(errorMessage)")
        }
    }
    
    static func audioSessionDidActivate(_ audioSession: AVAudioSession) {
        RTCAudioSession.sharedInstance().audioSessionDidActivate(audioSession)
        RTCAudioSession.sharedInstance().isAudioEnabled = true
    }
    
    static func audioSessionDidDeactivate(_ audioSession: AVAudioSession) {
        RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
        RTCAudioSession.sharedInstance().isAudioEnabled = false
    }
    
    //MARK: fileprivate
    fileprivate func createMediaSenders() {
        let id = getUniqueID()
        let stream = self.factory.mediaStream(withStreamId: id)
        
        if !isVoiceOnlyCall {
            startSendingVideoIn(stream: stream)
        }
        
        startSendingAudioIn(stream: stream)
        
        self.peerConnection?.add(stream)
    }
    
    fileprivate func startSendingVideoIn(stream: RTCMediaStream) {
        let videoTrack = self.createVideoTrack()
        stream.addVideoTrack(videoTrack)
        self.localVideoTrack = videoTrack
    }
    
    fileprivate func startSendingAudioIn(stream: RTCMediaStream) {
        let audioTrack = self.createAudioTrack()
        stream.addAudioTrack(audioTrack)
    }
    
    fileprivate func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = self.factory.audioSource(with: audioConstrains)
        let id = getUniqueID()
        let audioTrack = self.factory.audioTrack(with: audioSource, trackId: id)
        return audioTrack
    }
    
    fileprivate func createVideoTrack() -> RTCVideoTrack {
        let videoSource = self.factory.videoSource()
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        let id = getUniqueID()
        let videoTrack = self.factory.videoTrack(with: videoSource, trackId: id)
        return videoTrack
    }
    
    fileprivate func getUniqueID() -> String {
        let uuid = UUID()
        return uuid.uuidString
    }
    
    fileprivate func renderLocalVideoIn(view: UIView) {
        _ = removeVideoFrom(view: view)
        
        let localRenderer = getRendererFor(view: view)
        self.localVideoRenderer = localRenderer
        embed(view: localRenderer, in: view, withAspectRatio: localVideoAspectRatio)
        startCaptureLocalVideo()
        self.localVideoTrack?.add(localRenderer)
    }
    
    fileprivate func renderRemoteVideoIn(view: UIView) {
        
        _ = self.removeVideoFrom(view: view)
        
        let remoteRenderer = self.getRendererFor(view: view)
        self.remoteVideoRenderer = remoteRenderer
        
        guard self.remoteStream != nil else {
            return
        }
        self.remoteStream?.videoTracks.first?.add(remoteRenderer)
        
        self.embed(view: remoteRenderer, in: view, withAspectRatio: remoteVideoAspectRatio)
    }
    
    fileprivate func embed(view: RTCVideoRenderer, in superView: UIView, withAspectRatio ratio: CGSize?) {
        switch view {
        case let videoView as RTCEAGLVideoView:
            superView.addSubview(videoView)
            let aspectRatio = ratio ?? defaultAspectRatio
            setRectOf(view: videoView, in: superView, withAspectRatio: aspectRatio)
            #if arch(arm64)
        case let videoView as RTCMTLVideoView:
            superView.addSubview(videoView)
            setConstraintsOf(view: videoView, in: superView)
            #endif
        default:
            break
        }
    }
    
    fileprivate func setRectOf(view: UIView, in superView: UIView, withAspectRatio ratio: CGSize) {
        guard ratio.width != 0 && ratio.width != 0 else {
            return
        }
        
        let videoRect = AVMakeRect(aspectRatio: ratio, insideRect: superView.bounds)
        view.frame = videoRect
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
    }
    
    fileprivate func setConstraintsOf(view: UIView, in superView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
        view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
    }
    
    
    ///Returns removed video renderer
    @discardableResult
    fileprivate func removeVideoFrom(view: UIView) -> RTCVideoRenderer? {
        for subview in view.subviews {
            if subview is RTCVideoRenderer {
                subview.removeFromSuperview()
                return subview as? RTCVideoRenderer
            }
        }
        
        return nil
    }
    
    fileprivate func getRendererFor(view: UIView) -> RTCVideoRenderer {
        #if arch(arm64)
        // Using metal (arm64 only)
        let renderer = RTCMTLVideoView(frame: view.bounds)
        renderer.videoContentMode = .scaleAspectFit
        #else
        // Using OpenGLES for the rest
        let renderer = RTCEAGLVideoView(frame: view.bounds)
        renderer.delegate = self
        #endif
        
        return renderer
    }
    
    fileprivate func startCaptureLocalVideo() {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
            return
        }
        
        guard
            let camera = getCurrentCamera(),
            let format = getVideoFormatFor(camera: camera),
            let fps = getFPSFor(format: format) else {
                return
        }
        
        capturer.startCapture(with: camera,
                              format: format,
                              fps: Int(fps))
    }
    
    fileprivate func getCurrentCamera() -> AVCaptureDevice? {
        let currentCameraPosition: AVCaptureDevice.Position = isUsingFrontCamera ? .front : .back
        for camera in RTCCameraVideoCapturer.captureDevices() {
            if camera.position == currentCameraPosition {
                return camera
            }
        }
        
        return nil
    }
    
    fileprivate func getVideoFormatFor(camera: AVCaptureDevice) -> AVCaptureDevice.Format? {
        
        let formats = RTCCameraVideoCapturer.supportedFormats(for: camera).sorted { (f1, f2) -> Bool in
            let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
            let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
            return width1 < width2
        }
        
        // choosing average res
        let formatCount = formats.count
        guard formatCount > 2 else {
            return formats.last
        }
        
        let averageFormatIndex = (formatCount/2) + 1
        let averageFormat = formats[averageFormatIndex]
        
        return averageFormat
    }
    
    fileprivate func getFPSFor(format: AVCaptureDevice.Format) -> Float64? {
        // choosing highest fps
        #if swift(>=4.2)
        let frames = format.videoSupportedFrameRateRanges
        #else
        guard let frames = format.videoSupportedFrameRateRanges as? [AVFrameRateRange] else {
            return nil
        }
        #endif
        //        guard let frames = format.videoSupportedFrameRateRanges as? [AVFrameRateRange] else {
        //            return nil
        //        }
        let fps: AVFrameRateRange? = frames.sorted {(f1, f2) -> Bool in
            return f1.maxFrameRate < f2.maxFrameRate
            }.last
        return fps?.maxFrameRate
    }
    
    fileprivate func isHeadphonePluggedIn() -> Bool {
        let route = RTCAudioSession.sharedInstance().currentRoute
        
        for desc in route.outputs {
            #if swift(>=4.2)
            let isPortTypeHeadPhone = desc.portType == AVAudioSession.Port.headphones || desc.portType == AVAudioSession.Port.bluetoothHFP
            #else
            let isPortTypeHeadPhone = desc.portType == AVAudioSessionPortHeadphones || desc.portType == AVAudioSessionPortBluetoothHFP
            #endif
            
            if isPortTypeHeadPhone {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func getCurrentAudioStream() -> RTCAudioTrack? {
        let stream = peerConnection?.localStreams.first
        let audioTrack = stream?.audioTracks.first
        return audioTrack
    }
    
    fileprivate func getCurrentVideoStream() -> RTCVideoTrack? {
        let stream = peerConnection?.localStreams.first
        let videoTrack = stream?.videoTracks.first
        return videoTrack
    }
    
    // MARK: - RTCPeerConnectionDelegate
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("didChange stateChanged RTCSignalingState to \(stateChanged.hashValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        self.remoteStream = stream
        
        if let remoteVideoView = delegate?.viewForRenderingRemoteVideo() {
            DispatchQueue.main.async {
                self.renderRemoteVideoIn(view: remoteVideoView)
            }
        }
        print("didAdd stream with \(stream.streamId)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("didRemove stream")
    }
    
    /** Called when negotiation is needed, for example ICE has restarted. */
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("peerConnectionShouldNegotiate")
    }
    
    /** Called any time the IceConnectionState changes. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("didChange newState: RTCIceConnectionState: \(newState.rawValue)")
        
        switch newState {
        case .failed, .closed:
            DispatchQueue.main.async {
                self.delegate?.rtcConnectionDisconnected()
            }
        case .disconnected:
            DispatchQueue.main.async {
               self.delegate?.rtcConnectionRetry()
            }
        case .completed, .connected:
            DispatchQueue.main.async {
                self.delegate?.rtcConnecetd()
            }
        default:
            break
        }
    }
    
    /** Called any time the IceGatheringState changes. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("didChange gatheringState")
    }
    
    /** New ice candidate has been found. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("didGenerate candidate")
        let candidateJson = candidate.jsonDictionary()
        delegate?.sendCandidateViaSignalling(json: candidateJson)
    }
    
    /** Called when a group of local Ice candidates have been removed. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("didRemove candidates")
    }
    
    /** New data channel has been opened. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("didOpen dataChannel")
    }
    
    /** Called when signaling indicates a transceiver will be receiving media from
     *  the remote endpoint.
     *  This is only called with RTCSdpSemanticsUnifiedPlan specified.
     */
    func peerConnection(_ peerConnection: RTCPeerConnection, didStartReceivingOn transceiver: RTCRtpTransceiver) {
        print("didStartReceivingOn")
    }
    
    /** Called when a receiver and its track are created. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd rtpReceiver: RTCRtpReceiver, streams mediaStreams: [RTCMediaStream]) {
        print("didAdd rtpReceiver")
    }
    
    /** Called when the receiver and its track are removed. */
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove rtpReceiver: RTCRtpReceiver) {
        print("didRemove rtpReceiver")
    }
    
    deinit {
        RTCAudioSession.sharedInstance().isAudioEnabled = false
        RTCAudioSession.sharedInstance().useManualAudio = false
        print("WebRTCCLient deintialized")
    }
}

extension CallClientCredential {
    func getIceServers() -> [RTCIceServer] {
        var iceServers = [RTCIceServer]()
        
        for stun in stunIceServers {
            let iceServer = RTCIceServer(urlStrings: [stun.domainName])
            iceServers.append(iceServer)
        }
        
        var urls = [String]()
        for turn in turnIceServers {
            urls.append(turn.domainName)
        }
        
        let turnServer = RTCIceServer(urlStrings: urls, username: username, credential: password)
        iceServers.append(turnServer)
        return iceServers
    }
}

extension WebRTCClient: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        switch (videoView as? UIView) {
        case localVideoRenderer as? UIView:
            self.localVideoAspectRatio = size
            frameOfLocalVideoContainerViewChanged()
        case remoteVideoRenderer as? UIView:
            self.remoteVideoAspectRatio = size
            frameOfRemoteVideoContainerViewChanged()
        default:
            break
        }
        
        
    }
    
    
}



