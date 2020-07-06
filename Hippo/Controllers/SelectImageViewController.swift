//
//  SelectImageViewController.swift
//  Fugu
//
//  Created by Aditi on 8/29/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit
//import Kingfisher
protocol SelectImageViewControllerDelegate: class {
    func selectImageVC(_ selectedImageVC: SelectImageViewController, selectedImage: UIImage)
    func goToConversationViewController()
}

class SelectImageViewController: UIViewController {
    
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    
    
    weak var delegate: SelectImageViewControllerDelegate?
    var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectImageView.image = pickedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        selectImageView.image = nil
        print("view will disappear ")
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BackButton(_ sender: Any) {
        self.delegate?.goToConversationViewController()
    }
    
    @IBAction func sendButton(_ sender: Any) {
        guard let selectedImage = pickedImage else { return }
        self.delegate?.selectImageVC(self, selectedImage: selectedImage)
    }
    
//    class func get(delegate: SelectImageViewControllerDelegate, result: CoreMediaSelector.Result) -> SelectImageViewController? {
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "SelectImageViewController") as? SelectImageViewController else {
//            return nil
//        }
//        return vc
//    }
//
//    class func get(delegate1: SelectImageViewControllerDelegate) -> SelectImageViewController? {
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "SelectImageViewController") as? SelectImageViewController else {
//            return nil
//        }
//        return vc
//    }
    
    // MARK: - Type Methods
    class func getWith(pickedImage: UIImage, imageFormat: ImageFormat?, delegate: SelectImageViewControllerDelegate?, isMentioningEnabled: Bool, gifData: Data?, mediaType: CoreMediaSelector.Result.MediaType) -> SelectImageViewController {
        //        let destinationVC = findIn(storyboard: .fuguUnique, withIdentifier: "SelectImageViewController") as! SelectImageViewController
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "SelectImageViewController") as! SelectImageViewController
        destinationVC.pickedImage = pickedImage
        //        destinationVC.tempImg = pickedImage
        destinationVC.delegate = delegate
        //        destinationVC.memberManager = memberManager
        //        destinationVC.pickedImageFormat = imageFormat ?? ImageFormat.JPEG
        //        destinationVC.isMentionEnabled = isMentioningEnabled
        //        destinationVC.gifData = gifData
        return destinationVC
    }
    
}

//import UIKit
//import Kingfisher
//import FuguShare
//import SZMentionsSwift
//
//protocol SelectImageViewControllerDelegate: class {
//    func selectImageVC(_ selectedImageVC: SelectImageViewController, selectedImage: UIImage, info: FuguImageInfo, gifData: Data?)
//}
//
//struct FuguImageInfo {
//    let format: ImageFormat
//    let message: String
//    let mentions: [Mention]
//}
//
//class SelectImageViewController: MasterViewController {
//
//    // MARK: - IBOutlets
//    @IBOutlet weak var selectImageView: UIImageView!
//    @IBOutlet weak var dummyViewToGetVisibleFrame: UIView!
//    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var sendingViewContainer: UIView!
//    //Raghav Goel
//    @IBOutlet weak var cropImageButton: UIButton!
//
//    // MARK: - Properties
//    weak var delegate: SelectImageViewControllerDelegate?
//    var pickedImage: UIImage?
//    var pickedImageFormat: ImageFormat?
//    var memberManager: ChannelMembersDataManager?
//
//    var messageSendingView: MessageSendingView?
//    var isMentionEnabled = false
//
//    //Raghav Goel
//    var tempImg: UIImage?
//    var gifData: Data?
//
//    // MARK: - View Life Cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupMessageSendingView()
//        makeTextViewMoveWithRespectToKeyboard()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        selectImageView.image = pickedImage
//
//        if gifData != nil || pickedImageFormat == .GIF {
//            cropImageButton.isHidden = true
//
//            if let someData = gifData {
//                let newImage = UIImage.animatedImageWithData(someData)
//                selectImageView.image = newImage
//            }
//        }
//    }
//
//
//
//    override func viewWillDisappear(_ animated: Bool) {
//        selectImageView.image = nil
//    }
//
//    // MARK: - IBActions
//    @IBAction func cancelButton(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func cropViewTapped(_ sender: Any) {
//        self.view.endEditing(true)
//        guard let image = tempImg else {
//            return
//        }
//
//        let controller = CropViewController()
//        controller.delegate = self
//        controller.image = image
//        let navController = UINavigationController(rootViewController: controller)
//        present(navController, animated: true, completion: nil)
//    }
//
//    // MARK: - Methods
//    func setupMessageSendingView() {
//
//        guard messageSendingView == nil else {
//            return
//        }
//
//        let mentionAttributes: [String: NSObject] = [
//            NSAttributedStringKey.font.rawValue: FuguConfig.shared.theme.typingTextFont!,
//            NSAttributedStringKey.foregroundColor.rawValue: UIColor.defaultTintColor
//        ]
//
//        let typingAttributes: [String: NSObject] = [
//            NSAttributedStringKey.font.rawValue: FuguConfig.shared.theme.typingTextFont!,
//            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white
//        ]
//
//        let initRequest = MessageSendingView.IntializingRequest(text: "", existingMentions: [], sendingViewDelegate: self, isMentioningEnabled: isMentionEnabled, sendingFilesEnabled: true, mentionAttributes: mentionAttributes, botMentionAttributes: nil, defaultTextAttributes: typingAttributes, dataManager: memberManager!, triggersForMentioning: ["@"])
//
//        let sendTextButton = MessageSendingView.ButtonUIAttributes(title: nil, image: FuguConfig.shared.theme.sendBtnIcon, isHidden: false)
//        let sendFileButton = MessageSendingView.ButtonUIAttributes(title: nil, image: FuguConfig.shared.theme.addButtonIcon, isHidden: true)
//        let placeholderLabel = MessageSendingView.LabelUIAttributes(textColor: UIColor.gray, text: "Add a Caption...")
//        let backgroundView = MessageSendingView.ViewUIAttributes(color: .black)
//
//        let uiAttributes = MessageSendingView.UIAttributes(sendTextButton: sendTextButton, sendFileButton: sendFileButton, backgroundView: backgroundView, placeholderLabel: placeholderLabel)
//
//        messageSendingView = MessageSendingView.getWith(request: initRequest, uiAttributes: uiAttributes)
//
//        messageSendingView?.translatesAutoresizingMaskIntoConstraints = false
//        messageSendingView?.isSendingButtonShouldEnable = true
//
//        view.addSubview(messageSendingView!)
//
//        sendingViewContainer.leadingAnchor.constraint(equalTo: messageSendingView!.leadingAnchor, constant: 0).isActive = true
//        sendingViewContainer.trailingAnchor.constraint(equalTo: messageSendingView!.trailingAnchor, constant: 0).isActive = true
//        sendingViewContainer.firstBaselineAnchor.constraint(equalTo: messageSendingView!.firstBaselineAnchor, constant: 0).isActive = true
//        sendingViewContainer.bottomAnchor.constraint(equalTo: messageSendingView!.bottomAnchor, constant: 0).isActive = true
//    }
//
//    func makeTextViewMoveWithRespectToKeyboard() {
//        let inputView = FrameObserverAccessaryView(frame: messageSendingView?.bounds ?? CGRect.zero)
//        inputView.isUserInteractionEnabled = false
//
//        messageSendingView?.inputAccessoryView = inputView
//
//        inputView.changeKeyboardFrame { [weak self] (keyboardVisible, keyboardFrame) in
//            guard self?.isViewLoaded == true else {
//                return
//            }
//            let value = UIScreen.main.bounds.height - keyboardFrame.minY - UIView.safeAreaInsetsForAllOS.bottom
//            let maxValue = max(0, value)
//            self?.textViewBottomConstraint.constant = maxValue
//
//            self?.view.layoutIfNeeded()
//
//            self?.messageSendingView?.maxMentionViewHeight = self?.dummyViewToGetVisibleFrame.bounds.height ?? 150
//        }
//    }
//
//    // MARK: - Type Methods
//    class func getWith(pickedImage: UIImage, imageFormat: ImageFormat?, delegate: SelectImageViewControllerDelegate?, memberManager: ChannelMembersDataManager, isMentioningEnabled: Bool, gifData: Data?) -> SelectImageViewController {
//        let destinationVC = findIn(storyboard: .fuguUnique, withIdentifier: "SelectImageViewController") as! SelectImageViewController
//        destinationVC.pickedImage = pickedImage
//        destinationVC.tempImg = pickedImage
//        destinationVC.delegate = delegate
//        destinationVC.memberManager = memberManager
//        destinationVC.pickedImageFormat = imageFormat ?? ImageFormat.JPEG
//        destinationVC.isMentionEnabled = isMentioningEnabled
//        destinationVC.gifData = gifData
//        return destinationVC
//    }
//}
//
//
//// MARK: - MessageSendingViewDelegate
//extension SelectImageViewController: MessageSendingViewDelegate {
//    func saveEditedMessageButtonTappedWith(string: String, mentions: [Mention]) {}
//
//    func cancelEditingMessage() {}
//
//    func sendMessageButtonTappedWith(string: String, mentions: [Mention]) {
//        messageSendingView?.resignFirstResponder()
//
//        let message = string.trimWhiteSpacesAndNewLine()
//
//        let imageInfo = FuguImageInfo(format: pickedImageFormat ?? .JPEG, message: message, mentions: mentions)
//        DispatchQueue.main.async {
//            if let image = self.selectImageView.image{
//                self.delegate?.selectImageVC(self, selectedImage: image, info: imageInfo, gifData: self.gifData)
//            }
//            else{
//                self.delegate?.selectImageVC(self, selectedImage: self.pickedImage!, info: imageInfo, gifData: self.gifData)
//            }
//        }
//    }
//
//    func sendFileButtonTapped(_ sender: UIButton) {}
//
//    func imagePasted() {}
//
//    func typingStartedInTextView() {}
//
//    func typing() {}
//
//    func typingStoppedInTextView() {}
//}
//
//
//extension SelectImageViewController: CropViewControllerDelegate {
//    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
//        selectImageView.image = image
//        pickedImage = image
//    }
//
//
//    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
//        controller.dismiss(animated: true, completion: nil)
//        selectImageView.image = image
//        pickedImage = image
//    }
//
//    func cropViewControllerDidCancel(_ controller: CropViewController) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//}
//
//
////extension UIImage {
////    public class func gifImageWithData(_ data: Data) -> UIImage? {
////        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
////            print("image doesn't exist")
////            return nil
////        }
////
////        return UIImage.animatedImageWithSource(source)
////    }
////}
