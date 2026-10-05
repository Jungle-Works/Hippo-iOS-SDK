//
//  PreviewViewController.swift
//  HippoAgent
//
//  Created by Arohi Sharma on 10/02/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import CropViewController

class PreviewViewController: UIViewController {
    
    //MARK:- IBOutlet
    @IBOutlet private var viewNavigation : NavigationBar!
    @IBOutlet var textView_PrivateNotes : UITextView!{
        didSet{
            textView_PrivateNotes.delegate = self
        }
    }
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet var imageView_Preview : UIImageView!
    @IBOutlet var label_Placeholder : UILabel!{
        didSet{
            label_Placeholder.text = HippoStrings.messagePlaceHolderText
        }
    }
    @IBOutlet weak var lblDocumentName: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    //MARK:- Properties
    var image : UIImage?
    var fileType : FileType?
    var sendBtnTapped : ((String?, UIImage?)->())?
    var path: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewNavigation.leftButton.addTarget(self, action: #selector(action_BackBtn), for: .touchUpInside)
        textView_PrivateNotes.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        setupSendButton()
        if fileType == .document{
            imageView_Preview.contentMode = .center
            imageView_Preview.image = UIImage(named: "defaultDoc", in: FuguFlowManager.bundle, compatibleWith: nil)
            viewNavigation.title = HippoStrings.document
            lblDocumentName.text = path?.lastPathComponent
        }else if fileType == .video{
            // Videos get a still from their first second plus a play glyph, so the user can
            // see what they're sending and add a caption, like with photos.
            imageView_Preview.image = path.flatMap(PreviewViewController.thumbnail(forVideoAt:))
            viewNavigation.title = HippoStrings.preview
            imageView_Preview.contentMode = .scaleAspectFit
            addPlayGlyph()
        }else{
            imageView_Preview.image = image
            viewNavigation.title = HippoStrings.preview 
            imageView_Preview.contentMode = .scaleAspectFit
        }
        
        lblDocumentName.isHidden = !(fileType == .document)
        // Crop is for still images only (camera or gallery) - not documents or videos, and
        // not animated GIFs, which a crop would flatten to a single frame.
        btnEdit.isHidden = fileType == .document || fileType == .video || image == nil || image?.images != nil
    }
    
    /// Frame near the start of the video, upright (honours the recording orientation).
    private static func thumbnail(forVideoAt url: URL) -> UIImage? {
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        generator.appliesPreferredTrackTransform = true
        // 1s in skips a black first frame; very short clips fall back to the start.
        let oneSecond = CMTime(seconds: 1, preferredTimescale: 600)
        let frame = (try? generator.copyCGImage(at: oneSecond, actualTime: nil))
            ?? (try? generator.copyCGImage(at: .zero, actualTime: nil))
        return frame.map(UIImage.init(cgImage:))
    }
    
    /// Play button over the thumbnail that plays the picked video. Added to the main view,
    /// not the image view, since UIImageView ignores touches by default.
    private func addPlayGlyph() {
        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
        let play = UIButton(type: .system)
        play.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        play.tintColor = UIColor.white.withAlphaComponent(0.9)
        play.translatesAutoresizingMaskIntoConstraints = false
        play.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        view.addSubview(play)
        NSLayoutConstraint.activate([
            play.centerXAnchor.constraint(equalTo: imageView_Preview.centerXAnchor),
            play.centerYAnchor.constraint(equalTo: imageView_Preview.centerYAnchor)
        ])
    }

    @objc private func playVideo() {
        guard let url = path else { return }
        let playerController = AVPlayerViewController()
        playerController.player = AVPlayer(url: url)
        present(playerController, animated: true) {
            playerController.player?.play()
        }
    }
    
    /// Customer: same send glyph + tint as the chat composer's send button, falling back to
    /// the "Send" title only when the host app has cleared `sendBtnIcon`.
    /// Agent: keeps the original "Send" text button (the storyboard is laid out for the
    /// customer icon - 45pt wide, 12pt from the edge - so the old 120pt / flush layout is
    /// restored here).
    private func setupSendButton() {
        guard HippoConfig.shared.appUserType == .customer else {
            sendBtn.setTitle(HippoStrings.send, for: .normal)
            sendBtn.constraints.first { $0.firstAttribute == .width && $0.secondItem == nil }?.constant = 120
            if let stack = sendBtn.superview, let bar = stack.superview {
                bar.constraints.first {
                    $0.firstAttribute == .trailing && $0.secondItem === stack && $0.secondAttribute == .trailing
                }?.constant = 0
            }
            return
        }
        guard let sendIcon = HippoConfig.shared.theme.sendBtnIcon else {
            sendBtn.setTitle(HippoStrings.send, for: .normal)
            return
        }
        sendBtn.imageView?.contentMode = .scaleAspectFit
        sendBtn.tintColor = HippoConfig.shared.theme.sendBtnIconTintColor ?? HippoConfig.shared.colorConfig.hippoAccent
        sendBtn.setImage(sendIcon, for: .normal)
        sendBtn.setTitle("", for: .normal)
    }

    // Enabled here rather than in viewDidLoad: the full-screen crop screen triggers
    // viewDidDisappear (which disables it), and the caption box needs it again on return.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HippoKeyboardManager.shared.enable = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        HippoKeyboardManager.shared.enable = false
        HippoKeyboardManager.shared.keyboardDistanceFromTextField = 0
    }
    
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        return img
    }
    
}

extension PreviewViewController : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        label_Placeholder.isHidden = !(textView.text.isEmpty)
    }
}

extension PreviewViewController{
    @IBAction func action_SendBtn(){
        sendBtnTapped?(textView_PrivateNotes.text.trimWhiteSpacesAndNewLine(), self.image)
        action_BackBtn()
    }
    
    @IBAction func action_BackBtn(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnEditTapped(_ sender: Any) {
        presentCropViewController()
    }
    
    func presentCropViewController() {
        guard let image = image else { return }
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        // Wrapped in a nav controller on purpose: presented directly, CropViewController
        // uses its own custom transition, and dismissing that over this sheet-presented
        // preview tears the preview down too (leaving the chat's dimming view stuck).
        // The nav wrapper gets the standard transition; its bar is hidden since the
        // crop screen has its own toolbar.
        let nav = UINavigationController(rootViewController: cropViewController)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }

    /// Closes the crop screen only - this preview stays up so the user can send.
    private func dismissCropScreen() {
        guard presentedViewController != nil else { return }
        dismiss(animated: true, completion: nil)
    }
    
}

extension PreviewViewController : CropViewControllerDelegate{
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // The cropped image replaces the original - Send passes `self.image` back.
        self.image = image
        imageView_Preview.image = image
        dismissCropScreen()
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        dismissCropScreen()
    }
}
