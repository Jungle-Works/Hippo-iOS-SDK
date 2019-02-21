//
//  CreatePaymentViewController.swift
//  Hippo
//
//  Created by Vishal on 21/02/19.
//

import UIKit



class CreatePaymentViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    var datasource: CreatePaymentDataSource?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.navigationController?.setTheme()
        setUI()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setUI() {
        title = HippoProperty.current.formCollectorTitle
        if HippoConfig.shared.theme.leftBarButtonImage != nil {
            backButton.image = HippoConfig.shared.theme.leftBarButtonImage
            backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        }
    }
    func setupTableView() {
        datasource = CreatePaymentDataSource()
        tableView.dataSource = datasource
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        let bundle = FuguFlowManager.bundle
        
        tableView.register(UINib(nibName: "BroadCastTitleCell", bundle: bundle), forCellReuseIdentifier: "BroadCastTitleCell")
        tableView.register(UINib(nibName: "BroadcastButtonCell", bundle: bundle), forCellReuseIdentifier: "BroadcastButtonCell")
        tableView.register(UINib(nibName: "BroadCastTextFieldCell", bundle: bundle), forCellReuseIdentifier: "BroadCastTextFieldCell")
        tableView.register(UINib(nibName: "ContactNumberTableCell", bundle: bundle), forCellReuseIdentifier: "ContactNumberTableCell")
        
        
        tableView.tableFooterView = UIView()
    }
    
    class func get() -> CreatePaymentViewController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreatePaymentViewController") as! CreatePaymentViewController
        return vc
    }
    
}
extension CreatePaymentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case let customCell as BroadcastButtonCell:
            customCell.delegate = self
        case let customCell as BroadCastTextFieldCell:
            customCell.delegate = self
        default:
            return
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
extension CreatePaymentViewController: BroadCastTextFieldCellDelegate {
    func textFieldTextChanged(newText: String) {
        
    }
}
extension CreatePaymentViewController: BroadcastButtonCellDelegate {
    func previousMessageButtonClicked() {
        
    }
    
    func sendButtonClicked() {
        
    }
}

