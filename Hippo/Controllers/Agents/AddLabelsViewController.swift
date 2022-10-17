//
//  AddLabelsViewController.swift
//  Fugu
//
//  Created by Divyansh Bhardwaj on 16/03/18.
//  Copyright © 2018 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol  AddLabelProtocol: class {
    func addLabelAction(tagsArray: [TagDetail])
    func cancelAction()
}

class AddLabelsViewController: UIViewController {
    
    @IBOutlet weak var searchBarHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var labelsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addLabelsButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var plusButton: UIBarButtonItem!
    @IBOutlet weak var backItem: UIBarButtonItem!
    
    weak var delegate: AddLabelProtocol?
    var channelId: Int?
    var titleSearchBar = UISearchBar()
    
    var lastActiveStatus = [TagDetail]()
    var alterTags: [TagDetail] = []
    var filteredTags = [TagDetail]()
    var allTags = [TagDetail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpAddLablesScreen()
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fuguDelay(0.0) {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar.resignFirstResponder()
        self.titleSearchBar.resignFirstResponder()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: Add labels action
    @IBAction func addLabelsAction(_ sender: UIButton) {
        self.searchBar.resignFirstResponder()
        
        updateChannelTags { (success) in
            guard success else {
                return
            }
            self.delegate?.addLabelAction(tagsArray: self.lastActiveStatus)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: Create labels action
    @IBAction func createLabelsAction(_ sender: UIBarButtonItem) {
        self.searchBar.resignFirstResponder()
        pushToCreateLabel()
    }
    
    // MARK: Cancel button
    @IBAction func cancelsAction(_ sender: UIButton) {
        self.searchBar.resignFirstResponder()
        self.delegate?.addLabelAction(tagsArray: self.lastActiveStatus)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Cancel button
    @IBAction func backAction(_ sender: UIButton) {
        self.searchBar.resignFirstResponder()
        self.delegate?.addLabelAction(tagsArray: self.lastActiveStatus)
        self.navigationController?.popViewController(animated: true)
    }
    
    //Class methods
    class func get(channelId: Int, existingTags: [TagDetail]) -> AddLabelsViewController {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddLabelsViewController") as! AddLabelsViewController
        
        vc.channelId = channelId
        vc.lastActiveStatus = existingTags
        
        return vc
    }
    
    func setTheme() {
        view.backgroundColor = HippoConfig.shared.theme.backgroundColor
    }
}

extension AddLabelsViewController {
    
    func pushToCreateLabel() {
        let vc = CreateLabelViewController.get()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setUpAddLablesScreen() {
        registerCell()
        DispatchQueue.main.async {
            self.getAllTags(sortList: true)
        }
        setupNavigationBar()
        self.setUpSearchBar()
        
        addLabelsButton.backgroundColor = HippoConfig.shared.theme.themeColor
        addLabelsButton.setTitleColor(HippoConfig.shared.theme.backgroundColor, for: .normal)
        
        setTheme()
    }
    
    func registerCell() {
        labelsTableView.register(UINib(nibName: "CustomerTagsTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "CustomerTagsTableViewCell")
    }
    
    func setupNavigationBar() {
        backItem.tintColor = HippoConfig.shared.theme.headerTextColor
        plusButton.tintColor = HippoConfig.shared.theme.headerTextColor
        self.setNavBar(with: "Add Labels")
    }
    
    func setUpSearchBar() {
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Label"
        searchBar.barTintColor = UIColor.white
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        searchBar.tintColor = UIColor.white
        searchBar.backgroundColor = UIColor.white
        searchBar.backgroundImage = UIImage()
        
        titleSearchBar.sizeToFit()
        titleSearchBar.placeholder = "Search Label"
        titleSearchBar.barTintColor = UIColor.white
        titleSearchBar.returnKeyType = .done
        titleSearchBar.delegate = self
        titleSearchBar.frame = searchBar.frame
    }
    
    func getAllTags(sortList: Bool = false) {
        if CacheManager.getStoredTagDetail().isEmpty{
            ChatInfoManager.sharedInstance.getAllTags(showLoader: false, sortList: sortList, exsitingTagsArray: self.lastActiveStatus) { (result) in
                guard let tags = result else {
                    return
                }
                self.filteredTags = tags
                self.allTags = self.filteredTags
                CacheManager.storeTags(tags: tags.clone())
                Business.shared.tags = tags.clone()
                self.labelsTableView.reloadData()
            }
        }else{
            let tagsArray = TagDetail.parseTagDetailWithSelected(data: CacheManager.getStoredTagDetail().clone().getJsonToStore(), sortList: false, existingTagsArray: self.lastActiveStatus)
            
            self.filteredTags = tagsArray
            self.allTags = self.filteredTags
            self.labelsTableView.reloadData()
        }
    }
    
    func filterTagsForStore() {
        for each in alterTags {
            let index = lastActiveStatus.firstIndex { (t) -> Bool in
                return t.tagId == each.tagId
            }
            if let parsedIndex = index, !each.isSelected {
                lastActiveStatus.remove(at: parsedIndex)
            } else if each.isSelected {
                lastActiveStatus.append(each)
            }
        }
    }
}

extension AddLabelsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterLabels(searchString: searchText.lowercased())
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    func filterLabels(searchString: String) {
        
        if searchString.isEmpty {
            filteredTags = allTags
            self.labelsTableView.reloadData()
            return
        }
        
        let tempArr = allTags.filter { (c) -> Bool in
            let tagName =  (c.tagName ?? "").lowercased()
            return tagName.contains(searchString)
        }
        
        filteredTags = tempArr
        self.labelsTableView.reloadData()
    }
}

extension AddLabelsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerTagsTableViewCell", for: indexPath) as? CustomerTagsTableViewCell else {
            return UITableViewCell()
        }
        return cell.configureCustomerCell(resetProperties: false, tagsDetail: self.filteredTags[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let tag = filteredTags[indexPath.row]
        
        handleSelectionOf(tag: tag)
        tag.isSelected = !tag.isSelected
        
        self.labelsTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func handleSelectionOf(tag: TagDetail) {
        let lastAlertedTagIndex = alterTags.firstIndex { (t) -> Bool in
            return t.tagId == tag.tagId
        }
        
        if let parsedIndex = lastAlertedTagIndex {
            alterTags.remove(at: parsedIndex)
        } else {
            alterTags.append(tag)
        }
    }
}


extension AddLabelsViewController: CreateLabelDelegate {
    
    func createnewLabel(tagDetail: TagDetail, use: Bool) {
        self.allTags.append(tagDetail)
        CacheManager.storeTags(tags: allTags)
        Business.shared.tags = allTags.clone()
        self.filterLabels(searchString: searchBar?.text ?? "")
        
        if use {
            handleSelectionOf(tag: tagDetail)
            tagDetail.isSelected = true
        }
        self.labelsTableView.reloadData()
        
    }
}

extension AddLabelsViewController {
    func useNewCreatedLabel(tagDetail: TagDetail, appendToExisting: Bool = true, updateSortedData: Bool) {
        
        guard let status = tagDetail.status, let channelId = channelId, let tag_id = tagDetail.tagId else {
            return
        }
        
        let param = ["tag_id": tag_id,
                     "status": status,
                     "channel_id": channelId]
        
        if appendToExisting {
            self.lastActiveStatus.append(tagDetail)
        }
        
        ChatInfoManager.sharedInstance.useCreatedTag(showLoader: false, param: param) {[weak self] (result) in
            
            guard result != nil, self != nil else {
                return
            }
            
            if updateSortedData {
                self?.getAllTags()
            }
            
        }
    }
    
    func updateChannelTags(completion: @escaping ((_ success: Bool) -> ())) {
        guard let channelId = channelId else {
            completion(false)
            return
        }
        guard !alterTags.isEmpty else {
            completion(true)
            return
        }
        let request = ChatInfoManager.UpdateChannelTagRequest(tags: alterTags, channelId: channelId, enableLoader: true)
        ChatInfoManager.sharedInstance.updateChannelTags(request: request) {[weak self] (success) in
            self?.filterTagsForStore()
            completion(success)
        }
    }
    
}

extension UIViewController{
    func setNavBar(with title: String){
        let value: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: HippoConfig.shared.theme.headerTextColor,
                                                     NSAttributedString.Key.font: HippoConfig.shared.theme.headerTextFont ?? UIFont()]
        navigationItem.title = title
        navigationItem.hidesBackButton = true
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = value
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = value
            appearance.shadowImage = UIColor.black.withAlphaComponent(0.3).as1ptImage()
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}

extension UIColor {
    
    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
