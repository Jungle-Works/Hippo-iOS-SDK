//
//  CannedRepliesViewController.swift
//  Hippo
//
//  Created by sreshta bhagat on 06/04/21.
//

import UIKit
protocol CannedRepliesVCDelegate: class {
    func cannedMessage(_ cannedMessageVC: CannedRepliesViewController, cannedObject: CannedReply)
    func cannedClosed()
}

class CannedRepliesViewController: UIViewController {

    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var noSavedRepliesLabel: UILabel!
    @IBOutlet weak var tableViewCannedMessage: UITableView!
   
    
    weak var delegate: CannedRepliesVCDelegate?
    var arrayCannedReply = [CannedReply]()
    var permanentReply = [CannedReply]()
    var searchButtonStatus: Bool = true
    var searchString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayCannedReply = Business.shared.savedReplies
        permanentReply = Business.shared.savedReplies
        setUpCannedRepliesScreen()
        setTheme()
    }
    override func viewWillAppear(_ animated: Bool) {
        tableViewCannedMessage.register(UINib(nibName: "CannedMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "CannedMessageTableViewCell")

        getCannedMessages()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeBtnAction(_ sender: UIBarButtonItem) {
    self.delegate?.cannedClosed()
    self.navigationItem.titleView = nil
    navigationController?.popViewController(animated: true)
   }
    
    

@IBAction func searchBtnAction(_ sender: UIBarButtonItem) {
    
    switch searchButtonStatus {
    case true:
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchButtonStatus = false
    case false:
        arrayCannedReply = permanentReply
        navigationItem.titleView = nil
        searchButtonStatus = true
    }
}

    func setTheme() {
        //self.view.backgroundColor = HippoTheme.theme.systemBackgroundColor.primary
        let theme = HippoConfig.shared.theme
       // tableViewCannedMessage.backgroundColor = UIColor.white //theme.systemBackgroundColor.secondary
       // self.view.backgroundColor = theme.backgroundColor
    }
    //class methods
    class func get() -> CannedRepliesViewController {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        //let storyboard = UIStoryboard(name: StoryBoardName.ConversationFlow.rawValue, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CannedRepliesViewController") as! CannedRepliesViewController
        return vc
    }
}

//MARK: - UITableView Delegate And DataSource Methods
extension CannedRepliesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayCannedReply.count <= 0 {
            noSavedRepliesLabel.isHidden = false
        } else {
            noSavedRepliesLabel.isHidden = true
        }
        return arrayCannedReply.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        print("row number is ",indexPath.row)
        let cannedObject = arrayCannedReply[indexPath.row]
        cell.textLabel?.text = cannedObject.title ?? ""
        if let desc =  cannedObject.message {
            cell.detailTextLabel?.text = desc.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.cannedMessage(self, cannedObject: self.arrayCannedReply[indexPath.row])
        navigationItem.titleView = nil
        navigationController?.popViewController(animated: true)
    }
    
    
}

//MARK: - HELPERS
extension CannedRepliesViewController {
   func setUpCannedRepliesScreen() {
       setupNavigationBar()
//
////        self.searchBarButton.ImageNoRender = #imageLiteral(resourceName: "search_glass_icon")
////        self.searchBarButton.tintColor = UIColor.white
    }
    
    func setupNavigationBar() {
        //self.navigationController?.setTheme()
//        //setupCustomThemeOnNavigationBar(hideNavigationBar: false)
      self.navigationController?.isNavigationBarHidden = false
//       // self.navigationItem.title = HippoStrings.SavedReplies
//       //titleOfNavigationItem(barTitle: "Saved Replies")
//      //  setupCustomThemeOnNavigationBar(hideNavigationBar: false)
    }
}

//MARK: - APIs
extension CannedRepliesViewController {
    func getCannedMessages() {

       let enableLoader = Business.shared.savedReplies.isEmpty

        CannedReply.getCannedMessages(enableLoader: enableLoader) {[weak self] (response) in
            guard let result = response, let weakSelf = self else {
                return
            }
            self?.permanentReply = result
           self?.filterCannedReplies(searchString: weakSelf.searchString)
        }
    }
}


extension CannedRepliesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchString = searchText.lowercased()
        self.filterCannedReplies(searchString: searchText.lowercased())
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func filterCannedReplies(searchString: String) {
        
        if searchString.isEmpty {
            arrayCannedReply = permanentReply
            self.tableViewCannedMessage.reloadData()
            return
        }
        
        let tempArr = permanentReply.filter { (c) -> Bool in
            let title =  (c.title ?? "").lowercased()
            let message = (c.message ?? "").lowercased()
            return title.contains(searchString) || message.contains(searchString)
        }
        
        arrayCannedReply = tempArr
        self.tableViewCannedMessage.reloadData()
    }
}




