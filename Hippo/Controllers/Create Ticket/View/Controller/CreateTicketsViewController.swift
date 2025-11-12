//
//  CreateTicketsViewController.swift
//  HippoAgent
//
//  Created by Neha Vaish on 21/04/23.
//  Copyright © 2023 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import AVKit
import QuickLook


//MARK: - Enums

enum TicketsRows: CaseCountable {
    case customerName
    case customerEmail
    case subject
    case descriptionTV
    case group
    case priority
    case tags
    case attachmentsBtn
}

class CreateTicketsViewController: UIViewController{
    
    //MARK: - IbOutlets
    
    @IBOutlet weak var navBar: NavigationBar!
    @IBOutlet weak var createTicketBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Variables
    
    var pickerHelper: PickerHelper?
    var rows: [TicketsRows] = []
    var isCheckBoxOn = false
    var createTicketDataModel = CreateTicketDataModel()
    var issues = [String]()
    var priority = [String]()
    let frameOfActivityIndicator = CGRect(x: 15, y: 3, width: 50, height: 30)
    var attachmentData = [[String:String]]()
    var attachments = [AttachmentData]()
    var showImageVC = ShowImageViewController()
    var qldataSource: HippoQLDataSource?
    var userTags = HippoConfig.shared.userTags
   
    
    //MARK: - LifecycleFuncs
    
    override func viewDidLoad() {
        getLists()
        print(userTags)
        self.tableViewSetUp()
        self.createSuperArray()
        self.setUpViewWithNav()
        self.createTicketBtn.layer.cornerRadius = 6
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        self.tableView.isUserInteractionEnabled = false
//        attachments = HippoConfig.shared.attachments
//        for i in 0..<HippoConfig.shared.attachments.count{
//            attachmentData.append(["path": HippoConfig.shared.attachments[i].path, "type":HippoConfig.shared.attachments[i].type, "name": HippoConfig.shared.attachments[i].name])
//        }
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Custom Funcs
    
    func tableViewSetUp() {
        tableView.register(UINib(nibName: "TextFieldsTableViewCell", bundle: Bundle(for: TextFieldsTableViewCell.self)), forCellReuseIdentifier: "TextFieldsTableViewCell")
        tableView.register(UINib(nibName: "DropDownTableViewCell", bundle: Bundle(for: DropDownTableViewCell.self)), forCellReuseIdentifier: "DropDownTableViewCell")
        tableView.register(UINib(nibName: "AttachmentTableViewCell", bundle: Bundle(for: AttachmentTableViewCell.self)), forCellReuseIdentifier: "AttachmentTableViewCell")
        tableView.register(UINib(nibName: "DescriptionTableViewCell", bundle: Bundle(for: DescriptionTableViewCell.self)), forCellReuseIdentifier: "DescriptionTableViewCell")
        tableView.register(UINib(nibName: "TagsTableViewCell", bundle: Bundle(for: TagsTableViewCell.self)), forCellReuseIdentifier: "TagsTableViewCell")
        
        tableView.tableFooterView = UIView()
    }
    
    
    func createSuperArray(){
        rows = [.customerName,.customerEmail,.subject,.descriptionTV,.group, .priority,.attachmentsBtn]
        
        //        tableView.reloadData()
    }
    
    func setUpViewWithNav() {
        navBar.title = HippoConfig.shared.theme.createTicketText
        navBar.leftButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        navBar.rightButton.isHidden = true
        navBar.layer.masksToBounds = false
        navBar.layer.shadowRadius = 2.0
        navBar.layer.shadowOpacity = 0.5
        navBar.layer.shadowColor = UIColor.gray.cgColor
        navBar.layer.shadowOffset = CGSize(width: 0 , height: 2)
        navBar.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                            y: navBar.bounds.maxY - navBar.layer.shadowRadius,
                                                            width: navBar.bounds.width,
                                                            height: navBar.layer.shadowRadius)).cgPath
    }
    
    @objc func backButtonClicked() {
        dismiss(animated: true)
    }
    
    func clearFields(){
        self.createTicketDataModel.subject = ""
        self.createTicketDataModel.issueDescription = ""
        self.createTicketDataModel.issue = ""
        self.createTicketDataModel.priority = ""
        self.attachments.removeAll()
        self.attachmentData.removeAll()
        HippoConfig.shared.attachments.removeAll()
//        self.userTags.removeAll()
        self.tableView.reloadData()
        
    }
    
    
    //MARK: - API Hit
    
    
    func getLists(){
        var params = [String : Any]()
        params = ["app_secret_key":HippoConfig.shared.appSecretKey,
                  "fetch_list_items" : ["PRIORITIES","GROUPS"]
        ] as [String : Any]
//        activityIndicator.startAnimating()
//        self.activityIndicator.isHidden = false
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.createTicket.rawValue) { (response, error, _, statusCode) in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.tableView.isUserInteractionEnabled = true
            if error == nil{
                if let messageDict = ((response) as? [String:Any]){
                    if let data = messageDict["data"] as? [String:Any]{
                        self.issues = data["groups"] as? [String] ?? [""]
                        self.priority = data["priorities"] as? [String] ?? [""]
                        self.tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
                        self.tableView.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .automatic)
                        
                    }
                }
            }
        }
    }
    
    func createTicket(){
        var params = [String : Any]()
        params = ["app_secret_key":HippoConfig.shared.appSecretKey,
                  "is_create_ticket": 1,
                  "subject" : createTicketDataModel.subject ?? "",
                  "customer_email" : createTicketDataModel.customer_email ?? "",
                  "customer_name" : createTicketDataModel.customer_name ?? "",
                  "description" : createTicketDataModel.issueDescription ?? "",
                  "priority" : createTicketDataModel.priority ?? "",
                  "group" : createTicketDataModel.issue ?? "",
                  "tags": userTags] as [String : Any]
                  
        if attachmentData != []{
            params["attachments"] = self.attachmentData
        }
        print(params)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        createTicketBtn.isUserInteractionEnabled = false
        HTTPClient.makeConcurrentConnectionWith(method: .POST, showActivityIndicator: true, para: params, extendedUrl: AgentEndPoints.createTicket.rawValue) { (response, error, _, statusCode) in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.createTicketBtn.isUserInteractionEnabled = true
            if error == nil{
                if let messageDict = ((response) as? [String:Any]){
                    if let data = messageDict["data"] as? [String:Any]{
                        print(data)
                        let uid = data["uid"] as? Int
                        self.showAlert(title: "", message: "Ticket #\(uid ?? 0) created successfully.", actionComplete: { action in
                            self.clearFields()
                            self.dismiss(animated: true)
                        })
                    }
                }
            }
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func createTicketPressed(_ sender: UIButton) {
        if self.createTicketDataModel.customer_name == "" || self.createTicketDataModel.customer_name == nil{
            self.showAlert(title: "", message: "Please enter customer name.", actionComplete: nil)
        }else if self.createTicketDataModel.customer_email == "" || self.createTicketDataModel.customer_email ==  nil{
            self.showAlert(title: "", message: "Please enter customer email.", actionComplete: nil)
        }else if self.createTicketDataModel.subject == "" || self.createTicketDataModel.subject == nil{
            self.showAlert(title: "", message: "Please enter subject.", actionComplete: nil)
        }else if self.createTicketDataModel.issueDescription == "" || self.createTicketDataModel.issueDescription == nil{
            self.showAlert(title: "", message: "Please enter description.", actionComplete: nil)
        }else if self.createTicketDataModel.issue == nil{
            self.showAlert(title: "", message: "Please select group type.", actionComplete: nil)
        }else if self.createTicketDataModel.priority == nil{
            self.showAlert(title: "", message: "Please select priority.", actionComplete: nil)
        }else if self.createTicketDataModel.subject?.count ?? 0 < 10 {
            self.showAlert(title: "", message: "Please enter a valid Subject. Subject must contain at least 10 characters.", actionComplete: nil)
        }else{
            if (self.createTicketDataModel.customer_email ?? "").isValidEmail(){
                self.createTicket()
            } else{
                self.showAlert(title: "", message: "Please enter valid email.", actionComplete: nil)
            }
            
        }
    }
}

//MARK: - TableView Funcs

extension CreateTicketsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch rows[indexPath.row]{
        case .customerName:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldsTableViewCell", for: indexPath) as? TextFieldsTableViewCell else {
                return UITableViewCell()
            }
            cell.textField.withImage(direction: .Left, image: UIImage(named: "user", in: FuguFlowManager.bundle, compatibleWith: nil) ?? UIImage(), colorSeparator: .clear, colorBorder: UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1))
            cell.textField.placeholder = "Enter Name"
            if HippoConfig.shared.customer_name != ""{
                cell.textField.text = HippoConfig.shared.customer_name
                self.createTicketDataModel.customer_name = HippoConfig.shared.customer_name
            }else{
                cell.textField.text = self.createTicketDataModel.customer_name
            }
            cell.callBack = { text in
                
                self.createTicketDataModel.customer_name = text
                
            }
            
            return cell
        case .customerEmail:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldsTableViewCell", for: indexPath) as? TextFieldsTableViewCell else {
                return UITableViewCell()
            }
            cell.textField.withImage(direction: .Left, image: UIImage(named: "envelope", in: FuguFlowManager.bundle, compatibleWith: nil) ?? UIImage(), colorSeparator: UIColor.clear, colorBorder: UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1))
            
            cell.textField.placeholder = "Enter Email"
            if HippoConfig.shared.customer_email != ""{
                cell.textField.text = HippoConfig.shared.customer_email
                self.createTicketDataModel.customer_email = HippoConfig.shared.customer_email
            }else{
                cell.textField.text = self.createTicketDataModel.customer_email
            }
            cell.callBack = { text in
                self.createTicketDataModel.customer_email = text
            }
            return cell
            
        case .subject:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldsTableViewCell", for: indexPath) as? TextFieldsTableViewCell else {
                return UITableViewCell()
            }
            
            cell.textField.withImage(direction: .Left, image: UIImage(named: "subject", in: FuguFlowManager.bundle, compatibleWith: nil) ?? UIImage(), colorSeparator: UIColor.clear, colorBorder: UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1))
           
            if HippoConfig.shared.subject != ""{
                cell.textField.text = HippoConfig.shared.subject
                self.createTicketDataModel.subject = HippoConfig.shared.subject
            }else{
                cell.textField.text = self.createTicketDataModel.subject
            }
            
            cell.callBack = { text in
                self.createTicketDataModel.subject = text
            }
            cell.textField.placeholder = "Enter Subject"
            return cell
            
            
        case .descriptionTV:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTableViewCell", for: indexPath) as? DescriptionTableViewCell else {
                return UITableViewCell()
            }
            if HippoConfig.shared.issueDescription != ""{
                cell.textView.text = HippoConfig.shared.issueDescription
                self.createTicketDataModel.issueDescription = HippoConfig.shared.issueDescription
            }else{
                cell.textView.text = self.createTicketDataModel.issueDescription
            }
            
            cell.callBack = { text in
                self.createTicketDataModel.issueDescription = text
            }
            return cell
        case .group:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownTableViewCell", for: indexPath) as? DropDownTableViewCell else {
                return UITableViewCell()
            }
            cell.issuesDropDownTf.text = ""
            cell.arrayOfItms = issues
            cell.issuesDropDownTf.placeholder = "Select Group"
            cell.callBack = { text in
                self.createTicketDataModel.issue = text
            }
            return cell
            
        case .priority:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownTableViewCell", for: indexPath) as? DropDownTableViewCell else {
                return UITableViewCell()
            }
            cell.issuesDropDownTf.text = ""
            cell.arrayOfItms = priority
            cell.issuesDropDownTf.placeholder = "Select Priority"
            cell.callBack = { text in
                
                self.createTicketDataModel.priority = text
                
            }
            return cell
        case .tags:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagsTableViewCell", for: indexPath) as? TagsTableViewCell else {
                return UITableViewCell()
            }
            cell.tagsTextField.tintColor = .gray
            cell.tagsTextField.withImage(direction: .Left, image: UIImage(named: "tag", in: FuguFlowManager.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage(), colorSeparator: UIColor.clear, colorBorder: UIColor(red: 223/255, green: 230/255, blue: 236/255, alpha: 1))
           
            return cell
        case .attachmentsBtn:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentTableViewCell", for: indexPath) as? AttachmentTableViewCell else {
                return UITableViewCell()
            }
            
            cell.attachments = self.attachments
            cell.callBack = { item in
                self.pickerHelper = PickerHelper(viewController: self, enablePayment: false)
                self.pickerHelper?.present(sender: self.view, controller: self, isCreateTicket: true)
                self.pickerHelper?.delegate = self
            }
            cell.deleteCallBack = { index in
                for i in (0..<(self.attachments.count)).reversed() {
                    if i == index {
                        self.attachments.remove(at: index)
                        self.attachmentData.remove(at: index)
                        self.tableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .automatic)
                    }
                }
            }
            
            cell.imageCallBack = { path in
                if let localPath = path {
                    self.showImageVC = ShowImageViewController.getFor(imageUrlString: localPath)
                }
                self.modalPresentationStyle = .overFullScreen
                self.present(self.showImageVC, animated: true, completion: nil)
            }
            
            cell.videoCallBack = { fileURL , fileName in
               
                guard let fileURL = fileURL, DownloadManager.shared.isFileDownloadedWith(url: fileURL ) else {
                    HippoConfig.shared.log.debug("-------\nERROR\nFile is not downloaded\n--------", level: .error)
                    return
                }
               
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute:  {
                    var fileName = fileName ?? ""
                    if fileName.count > 10 {
                        let stringIndex = fileName.index(fileName.startIndex, offsetBy: 9)
                        fileName = String(fileName[..<stringIndex])
                    }
                    self.openQuicklookFor(fileURL: fileURL, fileName: fileName)
                })
               
            }
            cell.reload()
            return cell
            
        
        
        }
    }
    
   
    func openQuicklookFor(fileURL: String, fileName: String) {
       
        guard let localPath = DownloadManager.shared.getLocalPathOf(url: fileURL) else {
            return
        }
        
//        if fileURL.contains(".ogg") || fileURL.contains(".oga"){
//            let updatedUrl = fileURL.replacingOccurrences(of: " ", with: "%20")
//            showUnsupportedAlert(url: updatedUrl)
//            return
//        }
        
        let url = URL(fileURLWithPath: localPath)
        let qlItem = QuickLookItem(previewItemURL: url, previewItemTitle: fileName)
        
        let qlPreview = QLPreviewController()
        self.qldataSource = HippoQLDataSource(previewItems: [qlItem])
        qlPreview.delegate = self.qldataSource
        qlPreview.dataSource = self.qldataSource
        qlPreview.title = fileName
        //        qlPreview.setupCustomThemeOnNavigationBar(hideNavigationBar: false)
        qlPreview.navigationItem.hidesBackButton = false
        qlPreview.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(qlPreview, animated: true)
        //        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

//MARK: - ImagePicker Delegates

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


//MARK: - ImagePicker Delegates

extension CreateTicketsViewController: PickerHelperDelegate  {
    func payOptionClicked() {
        
    }
    
    
    func imagePickingError(mediaSelector: CoreMediaSelector, error: Error) {
        showAlert(title: "", message: error.localizedDescription, actionComplete: nil)
    }
    
    func fileSelectedWithBiggerSize(maxSizeAllowed: UInt) {
        showAlert(title: "", message: "File size should be smaller than \(maxSizeAllowed).", actionComplete: nil)
        
    }
    
    func imageViewPickerDidFinish(mediaSelector: CoreMediaSelector, with result: CoreMediaSelector.Result) {
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
                getLastVisibleController()?.showAlert(title: "", message: result.error?.localizedDescription ?? HippoStrings.somethingWentWrong, actionComplete: nil)
                return
            }
            
            let filePathUrl = URL(fileURLWithPath: filePath)
            sendSelectedDocumentWith(filePath: filePathUrl.path, fileName: filePathUrl.lastPathComponent, messageType: .attachment, fileType: FileType.video)
           }
    }
    
    func didPickDocumentWith(url: URL) {
        sendSelectedDocumentWith(filePath: url.path, fileName: url.lastPathComponent, messageType: .attachment, fileType: .document)
    }
    
    func sendConfirmedImage(image confirmedImage: UIImage, mediaType: CoreMediaSelector.Result.MediaType ) {
        var imageExtention: String = ".jpg"
        let imageData: Data?
        
        let imageSize =  confirmedImage.jpegData(compressionQuality: 1)!.count
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
        print("TicketURL \(ticketUrl)")
        //         self.urlUploaded?(ticketUrl)
        
        let request = FileUploader.RequestParams(path: message.localImagePath!, mimeType: message.mimeType ?? "application/octet-stream", fileName: message.fileName ?? "")
        let pathURL = URL.init(fileURLWithPath: message.localImagePath!)
        let dataOfFile = try? Data.init(contentsOf: pathURL, options: [])
        let fileSize = dataOfFile?.getFormattedSize()
        message.fileSize = fileSize
        print("Successsssss\(request)")
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        FileUploader.uploadFileWith(request: request, completion: {[weak self] (result) in
            
            guard result.isSuccessful else {
                completion(false)
                return
            }
            
            self?.attachmentData.append(["path": result.fileUrl ?? "", "type": message.mimeType ?? "application/octet-stream", "name": message.fileName ?? ""])
            self?.attachments.append(AttachmentData(path: result.fileUrl ?? "", type: message.mimeType ?? "application/octet-stream", name: message.fileName ?? ""))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self?.tableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .automatic)
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
            })
            print("urlfile: \(result.fileUrl ?? "")")
            completion(true)
        })
    }
    
}
