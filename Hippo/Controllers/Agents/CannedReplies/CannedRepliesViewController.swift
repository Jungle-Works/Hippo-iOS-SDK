////
////  CannedRepliesViewController.swift
////  Hippo
////
////  Created by Neha Vaish on 19/02/24.
////

import Foundation
import UIKit

protocol CannedRepliesVCDelegate: class {
    func cannedMessage(_ cannedMessageVC: CannedRepliesViewController, cannedObject: CannedReply)
    func cannedClosed()
}

class CannedRepliesViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var noSavedRepliesLabel: UILabel!
    @IBOutlet weak var cancelBarButton: UIButton!
    @IBOutlet weak var tableViewCannedMessage: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCannedMessages()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeBtnAction(_ sender: UIButton) {
        self.delegate?.cannedClosed()
        navigationController?.popViewController(animated: true)
    }


    //class methods
    class func get() -> CannedRepliesViewController {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CannedMessageTableViewCell", for: indexPath) as? CannedMessageTableViewCell else {
            return UITableViewCell()
        }

        return cell.configureCannedMessageCell(resetProperties: true, cannedObject: arrayCannedReply[indexPath.row])
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
        tableViewCannedMessage.delegate = self
        tableViewCannedMessage.dataSource = self
        tableViewCannedMessage.register(UINib(nibName: "CannedMessageTableViewCell", bundle: Bundle(for: CannedMessageTableViewCell.self)), forCellReuseIdentifier: "CannedMessageTableViewCell")
    }

    func setupNavigationBar() {
        titleLbl.text = "Saved Replies"
    }
}

//MARK: - APIs
extension CannedRepliesViewController {
    func getCannedMessages() {

        let enableLoader = Business.shared.savedReplies.isEmpty

        CannedReply.getCannedMessages() {[weak self] (response) in
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
            let sku =  (c.sku ?? "").lowercased()
            return title.contains(searchString) || message.contains(searchString) || sku.contains(searchString)
        }

        arrayCannedReply = tempArr
        self.tableViewCannedMessage.reloadData()
    }
}
