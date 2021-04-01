//
//  CreateTicketAttachmentHelper.swift
//  Hippo
//
//  Created by Arohi Magotra on 08/03/21.
//  Copyright © 2021 CL-macmini-88. All rights reserved.
//

import Foundation
protocol CreateTicketAttachmentHelperDelegate: class {
    func imagePickingError(mediaSelector: CoreMediaSelector, error: Error)
    func fileSelectedWithBiggerSize(maxSizeAllowed: UInt)
}


final
class CreateTicketAttachmentHelper {
    
    weak var delegate : CreateTicketAttachmentHelperDelegate?
    var urlUploaded: ((TicketUrl)->())?
    var openAttachment: Bool?{
        didSet{
            handleAttachmentButtonClicked()
        }
    }
    private var pickerHelper: PickerHelper?
    
    
    //MARK:- Functions
    
    private func handleAttachmentButtonClicked() {
        pickerHelper = PickerHelper(viewController: getLastVisibleController() ?? UIViewController(), enablePayment: false)
        pickerHelper?.present(sender: UIView(), controller: getLastVisibleController() ?? UIViewController())
        pickerHelper?.delegate = self
    }

    
    private func uploadFileFor(message: HippoMessage, completion: @escaping (_ success: Bool) -> Void) {
         guard message.localImagePath != nil else {
             completion(false)
             return
         }

         guard doesFileExistsAt(filePath: message.localImagePath!) else {
             completion(false)
             return
         }
         let ticketUrl = TicketUrl(name: message.fileName ?? "", url: message.fileUrl, isUploaded: false)
         self.urlUploaded?(ticketUrl)

         let request = FileUploader.RequestParams(path: message.localImagePath!, mimeType: message.mimeType ?? "application/octet-stream", fileName: message.fileName ?? "")
         
         let pathURL = URL.init(fileURLWithPath: message.localImagePath!)
         let dataOfFile = try? Data.init(contentsOf: pathURL, options: [])
         let fileSize = dataOfFile?.getFormattedSize()
         message.fileSize = fileSize
         
         FileUploader.uploadFileWith(request: request, completion: {[weak self] (result) in
           
             guard result.isSuccessful else {
                 completion(false)
                 return
             }
             let ticketUrl = TicketUrl(name: message.fileName ?? "", url: result.fileUrl, isUploaded: true)
             self?.urlUploaded?(ticketUrl)
             completion(true)
         })
     }

}
extension CreateTicketAttachmentHelper: PickerHelperDelegate  {
    func payOptionClicked() {
        
    }
    
    func imagePickingError(mediaSelector: CoreMediaSelector, error: Error) {
        self.delegate?.imagePickingError(mediaSelector: mediaSelector, error: error)
    }
    
    func fileSelectedWithBiggerSize(maxSizeAllowed: UInt) {
        self.delegate?.fileSelectedWithBiggerSize(maxSizeAllowed: maxSizeAllowed)
    }
    
    func imageViewPickerDidFinish(mediaSelector: CoreMediaSelector, with result: CoreMediaSelector.Result) {
        print(result)
        guard result.isSuccessful else {
            
            return
        }
        let mediaType = result.mediaType ?? .imageType
        switch mediaType {
        case .gifType, .imageType:
            guard let selectedImage = result.image else {
                getLastVisibleController()?.showAlert(title: "", message: result.error?.localizedDescription ?? HippoStrings.somethingWentWrong, actionComplete: nil)
                return
            }
            sendConfirmedImage(image: selectedImage, mediaType: mediaType)
        case .movieType:
            guard let filePath = result.filePath else {
                getLastVisibleController()?.showAlert(title: "", message: HippoStrings.somethingWentWrong, actionComplete: nil)
                return
            }
            let filePathUrl = URL(fileURLWithPath: filePath)
            sendSelectedDocumentWith(filePath: filePathUrl.path, fileName: filePathUrl.lastPathComponent, messageType: .attachment, fileType: FileType.video)
        }
    }
    
    func didPickDocumentWith(url: URL) {
        print(url)
        
        sendSelectedDocumentWith(filePath: url.path, fileName: url.lastPathComponent, messageType: .attachment, fileType: .document)
    }
    
    func sendConfirmedImage(image confirmedImage: UIImage, mediaType: CoreMediaSelector.Result.MediaType ) {
        var imageExtention: String = ".jpg"
        let imageData: Data?
        
        let imageSize =  confirmedImage.jpegData(compressionQuality: 1)!.count
        print(imageSize)
        
        let compressionRate = getCompressonRateForImageWith(size: imageSize)
        
        switch mediaType {
        case .gifType:
            imageExtention = ".gif"
            imageData = confirmedImage.kf.gifRepresentation() ?? confirmedImage.kf.jpegRepresentation(compressionQuality: 1)
        default:
            imageExtention = ".jpg"
            imageData = confirmedImage.jpegData(compressionQuality: compressionRate)
        }
        
        let imageName = Date.timeIntervalSinceReferenceDate.description + imageExtention
        let imageFilePath = getCacheDirectoryUrlForFileWith(name: imageName).path
        
        ((try? imageData?.write(to: URL(fileURLWithPath: imageFilePath), options: [.atomic])) as ()??)
        
        if imageFilePath.isEmpty == false {
            self.imageSelectedToSendWith(localPath: imageFilePath, imageSize: confirmedImage.size)
        }
    }
    
    func imageSelectedToSendWith(localPath: String, imageSize: CGSize) {
        let message = HippoMessage(message: "", type: .imageFile, uniqueID: "", localFilePath: localPath, chatType: .generalChat)
        message.imageWidth = Float(imageSize.width)
        message.imageHeight = Float(imageSize.height)
        message.fileName = localPath.fileName()
        uploadFileFor(message: message) { (success) in
            guard success else {
                return
            }
        }
    }

    func sendSelectedDocumentWith(filePath: String, fileName: String, messageType: MessageType, fileType: FileType) {
        guard doesFileExistsAt(filePath: filePath) else {
            return
        }
        let uniqueName = DownloadManager.generateNameWhichDoestNotExistInCacheDirectoryWith(name: fileName)
        saveDocumentInCacheDirectoryWith(name: uniqueName, orignalFilePath: filePath)
        let message = HippoMessage(message: "", type: messageType, uniqueID: "", imageUrl: nil, thumbnailUrl: nil, localFilePath: filePath, taggedUserArray: nil, chatType: .generalChat)
        
        message.fileName = uniqueName
        message.localImagePath = getCacheDirectoryUrlForFileWith(name: uniqueName).path
        uploadFileFor(message: message) { (success) in
            
        }
    }
    
    func getCompressonRateForImageWith(size: Int) -> CGFloat {
        var compressionRate: CGFloat = 1
        
        if size > 3*1024 {
            compressionRate = 0.3
        } else if size > 2*1024 {
            compressionRate = 0.5
        } else {
            compressionRate = 0.7
        }
        
        return compressionRate
    }
    
    func getCacheDirectoryUrlForFileWith(name: String) -> URL {
        let cacheDirectoryPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.path
        var fileUrl = URL.init(fileURLWithPath: cacheDirectoryPath)
        fileUrl.appendPathComponent(name)
        return fileUrl
    }
    
    func saveDocumentInCacheDirectoryWith(name: String, orignalFilePath: String) {
        
        let orignalFilePathURL = URL.init(fileURLWithPath: orignalFilePath)
        let fileUrl = getCacheDirectoryUrlForFileWith(name: name)
        
        try? FileManager.default.copyItem(at: orignalFilePathURL, to: fileUrl)
    }
    
    private func doesFileExistsAt(filePath: String) -> Bool {
        return (try? Data(contentsOf: URL(fileURLWithPath: filePath))) != nil
    }
    
}
struct TicketUrl{
    var name : String?
    var url : String?
    var isUploaded : Bool?
}
