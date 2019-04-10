//
//  BroadcastListViewController.swift
//  SDKDemo1
//
//  Created by Vishal on 26/07/18.
//

import UIKit


class BroadcastListViewController: UIViewController {
    
    //MARK: Variables
//    var broadcastList = [BroadcastInfo]()
    var store = BroadcastStore()
    
    //MARK: Outlets
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setupTableView()
        hideErrorMessage()
        hideLoader()
        store.delegate = self
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    class func get(store: BroadcastStore) -> BroadcastListViewController? {
        let storyboard = UIStoryboard(name: "HippoBroadCast", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "BroadcastListViewController") as? BroadcastListViewController
        vc?.store = store
        return vc
    }
}

extension BroadcastListViewController {
    
    internal func setUpView() {
        self.navigationController?.setTheme()
        
        self.navigationItem.title = HippoConfig.shared.theme.broadcastHistoryHeader
        self.view.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        if HippoConfig.shared.theme.leftBarButtonText.count > 0 {
            backButton.setTitle((" " + HippoConfig.shared.theme.leftBarButtonText), for: .normal)
            if HippoConfig.shared.theme.leftBarButtonFont != nil {
                backButton.titleLabel?.font = HippoConfig.shared.theme.leftBarButtonFont
            }
            backButton.setTitleColor(HippoConfig.shared.theme.leftBarButtonTextColor, for: .normal)
        } else {
            if HippoConfig.shared.theme.leftBarButtonImage != nil {
                backButton.setImage(HippoConfig.shared.theme.leftBarButtonImage, for: .normal)
                backButton.tintColor = HippoConfig.shared.theme.headerTextColor
            }
        }
        tableView.backgroundColor = UIColor.clear
        view.backgroundColor = HippoConfig.shared.theme.backgroundColor
    }
    func setupTableView() {
        let bundle = FuguFlowManager.bundle
        tableView.register(UINib(nibName: "BroadcastListTableViewCell", bundle: bundle), forCellReuseIdentifier: "BroadcastListTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
    }
}

extension BroadcastListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = store.broadcasts[indexPath.row]
        let vc = HippoBroadcaster.getBroadcastDetailInstance(broadcastDetail: detail)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

extension BroadcastListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentBottom = scrollView.contentOffset.y + tableView.frame.height
        let maxBottom = scrollView.contentSize.height - 30
        
        guard currentBottom > maxBottom else {
            return
        }
        store.getMoreBroadcast()
    }
}
extension BroadcastListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.broadcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getListCell(for: indexPath)
    }
    
    func getListCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BroadcastListTableViewCell", for: indexPath) as? BroadcastListTableViewCell else {
            return defaultCell()
        }
        let broadcast = store.broadcasts[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.setupCellWith(broadcast: broadcast)
        cell.setHomeUI()
        return cell
    }
    
    func defaultCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    
}
extension BroadcastListViewController: BroadcastStoreDelegate {
    func broadcastsUpdated(broadcasts: [BroadcastInfo]) {
        if broadcasts.isEmpty {
            showError(message: HippoConfig.shared.strings.noBroadcastAvailable)
            tableView.isHidden = true
            return
        }
        tableView.reloadData()
    }
    
    func hideLoader() {
        footerView.isHidden = true
        activityIndicator.stopAnimating()
    }
    func showPaginationLoader() {
        footerView.isHidden = false
        tableView.tableFooterView = footerView
        activityIndicator.startAnimating()
    }
    func showError(message: String) {
        guard !message.isEmpty else {
            return
        }
        errorLabel.text = message
        tableView.isHidden = true
        errorLabel.isHidden = false
    }
    func hideErrorMessage() {
        errorLabel.text = ""
        errorLabel.isHidden = true
        tableView.isHidden = false
    }
}
