//
//  CreatePaymentViewController.swift
//  Hippo
//
//  Created by Vishal on 21/02/19.
//

import UIKit

protocol CreatePaymentDelegate: class {
    func sendMessage(for store: PaymentStore)
}


class CreatePaymentViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    var datasource: CreatePaymentDataSource?
    var store: PaymentStore = PaymentStore()
    weak var delegate: CreatePaymentDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.navigationController?.setTheme()
        HippoKeyboardManager.shared.enable = true
        setUI()
        store.delegate = self
    }
    override func viewDidDisappear(_ animated: Bool) {
        HippoKeyboardManager.shared.enable = false
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setUI() {
        title = "Payment Request"
        if HippoConfig.shared.theme.leftBarButtonImage != nil {
            backButton.image = HippoConfig.shared.theme.leftBarButtonImage
            backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        }
    }
    func setupTableView() {
        datasource = CreatePaymentDataSource(store: store)
        tableView.dataSource = datasource
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        let bundle = FuguFlowManager.bundle
        
        tableView.register(UINib(nibName: "BroadCastTitleCell", bundle: bundle), forCellReuseIdentifier: "BroadCastTitleCell")
        tableView.register(UINib(nibName: "BroadcastButtonCell", bundle: bundle), forCellReuseIdentifier: "BroadcastButtonCell")
        tableView.register(UINib(nibName: "BroadCastTextFieldCell", bundle: bundle), forCellReuseIdentifier: "BroadCastTextFieldCell")
        tableView.register(UINib(nibName: "PaymentItemDescriptionCell", bundle: bundle), forCellReuseIdentifier: "PaymentItemDescriptionCell")
        tableView.register(UINib(nibName: "ShowMoreTableViewCell", bundle: bundle), forCellReuseIdentifier: "ShowMoreTableViewCell")
        
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
        case let customCell  as PaymentItemDescriptionCell:
            customCell.delegate = self
        case let customCell  as ShowMoreTableViewCell:
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
    func pickerSelected(currency: PaymentCurrency) {
        store.selectedCurrency = currency
    }
}
extension CreatePaymentViewController: BroadcastButtonCellDelegate {
    func previousMessageButtonClicked() {
        
    }
    
    func sendButtonClicked() {
        if let errorMesaage = store.validateStore() {
            showAlertWith(message: errorMesaage, action: nil)
            return
        }
        delegate?.sendMessage(for: store)
        self.navigationController?.popViewController(animated: true)
    }
}

extension CreatePaymentViewController: PaymentItemDescriptionCellDelegate {
    func updateHeightFor(_ cell: PaymentItemDescriptionCell) {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    func cancelButtonClicked(item: PaymentItem) {
        store.removeIndex(for: item)
    }
}


extension CreatePaymentViewController: ShowMoreTableViewCellDelegate {
    func buttonClicked(with form: PaymentField) {
        store.addNewItem()
    }
}

extension CreatePaymentViewController: PaymentStoreDelegate {
    func dataUpdate() {
        tableView.reloadData()
    }
}
