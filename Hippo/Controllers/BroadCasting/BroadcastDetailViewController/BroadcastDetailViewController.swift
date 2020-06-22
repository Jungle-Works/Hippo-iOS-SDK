//
//  BroadcastDetailViewController.swift
//  Fugu
//
//  Created by Vishal on 11/02/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit


class BroadcastDetailViewController: UIViewController {
    
    @IBOutlet weak var loaderImageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    var datasource: BroadcastDetailDataSource?
    var store: BroadcastDetailStore!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBackButton()
        hideErrorMessage()
        hideLoader()
        store.delegate = self
        startLoadingCell()
        store.getStatusFromInital()
        
        title = HippoStrings.broadcastDetails
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setupBackButton() {
        self.navigationController?.setTheme()
        
        self.navigationItem.title = HippoConfig.shared.theme.broadcastHistoryHeader
        self.view.backgroundColor = HippoConfig.shared.theme.backgroundColor
        
        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        backButton.image = HippoConfig.shared.theme.leftBarButtonImage
        
        
        tableView.backgroundColor = UIColor.clear
        view.backgroundColor = HippoConfig.shared.theme.backgroundColor
    }
    func setupTableView() {
        self.datasource = BroadcastDetailDataSource(broadcastDetail: store.broadcast, userList: store.users)
        tableView.dataSource = datasource
        tableView.delegate = self
        
//        tableView.separatorStyle = .none
        
        let bundle = FuguFlowManager.bundle
        tableView.register(UINib(nibName: "BroadcastListTableViewCell", bundle: bundle), forCellReuseIdentifier: "BroadcastListTableViewCell")
        tableView.register(UINib(nibName: "BroadcastUserStatusCell", bundle: bundle), forCellReuseIdentifier: "BroadcastUserStatusCell")
    }
    
    func cellSelectedWith(user: CustomerInfo) {
        guard let vc = HippoBroadcaster.getChatboxViewController(for: user) else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    class func get(store: BroadcastDetailStore) -> BroadcastDetailViewController {
        let storyboard = UIStoryboard(name: "HippoBroadCast", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "BroadcastDetailViewController") as! BroadcastDetailViewController
        vc.store = store
        return vc
    }
}
extension BroadcastDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case let customCell as BroadcastUserStatusCell:
            customCell.delegate = self
        default:
            return
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tableSection = BroadcastDetailDataSource.BroadcastDetailSections(rawValue: section) else {
            return nil
        }
        switch tableSection {
        case .header:
            return nil
        case .users:
            let detail = ChatInfoCell(infoImage: nil, nameOfCell: HippoStrings.recipients)
            return ChatInfoHeader.configureSectionHeader(headerInfo: detail)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let tableSection = BroadcastDetailDataSource.BroadcastDetailSections(rawValue: section) else {
            return 0
        }
        switch tableSection {
        case .header:
            return 0
        case .users:
            return 30
        }
    }
}
extension BroadcastDetailViewController: BroadcastUserStatusCellDelegate {
    func openChatButtonClickedFor(user: CustomerInfo) {
        cellSelectedWith(user: user)
    }
}
extension BroadcastDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentBottom = scrollView.contentOffset.y + tableView.frame.height
        let maxBottom = scrollView.contentSize.height - 30
        
        guard currentBottom > maxBottom else {
            return
        }
        store.getMoreUsers()
    }
}

extension BroadcastDetailViewController: BroadcastDetailStoreDelegate {
    func showPaginationLoader() {
        footerView.isHidden = false
        tableView.tableFooterView = footerView
        activityIndicator.startAnimating()
    }
    
    func usersListUpdated(users: [CustomerInfo]) {
        datasource?.updateUserList(userList: users)
        tableView.reloadData()
    }
    func hideLoader() {
        loaderImageView.isHidden = true
        tableView.alpha = 1.0
        loaderImageView.stopRotationAnimation()
        tableView.isUserInteractionEnabled = true
        footerView.isHidden = true
        activityIndicator.stopAnimating()
    }
    func showError(message: String) {
        guard !message.isEmpty else {
            return
        }
        errorLabel.text = message
        tableView.isHidden = true
    }
    func hideErrorMessage() {
        errorLabel.text = ""
        errorLabel.isHidden = true
        tableView.isHidden = false
    }
    func startLoadingCell() {
        loaderImageView.isHidden = false
        loaderImageView.startRotationAnimation()
        tableView.isUserInteractionEnabled = false
        tableView.alpha = 0.6
    }
}
