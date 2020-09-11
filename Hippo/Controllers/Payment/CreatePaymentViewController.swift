//
//  CreatePaymentViewController.swift
//  Hippo
//
//  Created by Vishal on 21/02/19.
//

import UIKit

protocol CreatePaymentDelegate: class {
    func sendMessage(for store: PaymentStore)
    func backButtonPressed(shouldUpdate: Bool)
    func paymentCardPayment(isSuccessful: Bool)
}


class CreatePaymentViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loaderView: So_UIImageView!
    @IBOutlet var view_Navigation : NavigationBar!
    
    //MARK: Variables
    var datasource: CreatePaymentDataSource?
//    var store: PaymentStore = PaymentStore()
    var store: PaymentStore!
    weak var delegate: CreatePaymentDelegate?
    
    var messageType = MessageType.none
    var shouldSavePaymentPlan : Bool?
    var isEditScreen : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.remembersLastFocusedIndexPath = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        HippoKeyboardManager.shared.enable = false
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if self.messageType == .paymentCard{
            delegate?.backButtonPressed(shouldUpdate: (isEditScreen ?? false) ? true : false)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    internal func initalizeView() {
        
        setupTableView()
        self.navigationController?.setTheme()
        HippoKeyboardManager.shared.enable = true
        
        setUI()
        if self.messageType == .paymentCard{
            setEditButton()
        }
        store.delegate = self
//        self.view.backgroundColor = HippoTheme.theme.systemBackgroundColor.secondary
    }
    internal func setEditButton() {
        let displayEditButton = store.displayEditButton
        guard displayEditButton else {
            return
        }
        view_Navigation.rightButton.setImage(HippoConfig.shared.theme.editIcon, for: .normal)
        view_Navigation.rightButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
    }
    
    internal func resetRightBarButton() {
        navigationItem.rightBarButtonItems = []
    }
    @objc internal func editButtonPressed() {
        store.isEditing = true
        self.dataUpdate()
        resetRightBarButton()
    }
    
    func setUI() {
        view_Navigation.title = store?.isCustomisedPayment ?? false ? HippoStrings.paymentRequest : HippoStrings.savedPlans
        if HippoConfig.shared.theme.leftBarButtonImage != nil {
            view_Navigation.image_back.image = HippoConfig.shared.theme.leftBarButtonImage
            view_Navigation.image_back.tintColor = HippoConfig.shared.theme.headerTextColor
        }
        
        view_Navigation.leftButton.addTarget(self, action: #selector(self.backButtonAction(_:)), for: .touchUpInside)
        
        loaderView.tintColor = HippoConfig.shared.theme.headerTextColor
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setupTableView() {
        datasource = CreatePaymentDataSource(store: store)
        datasource?.shouldSavePaymentPlan = self.shouldSavePaymentPlan
        tableView.dataSource = datasource
        tableView.delegate = self
//        tableView.backgroundColor = .clear
        
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
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
//        let vc = storyboard.instantiateViewController(withIdentifier: "CreatePaymentViewController") as! CreatePaymentViewController
        let vc = generateView()
        vc.initalizeView()
        return vc
    }
    
    class func get(channelId: UInt) -> CreatePaymentViewController {
        let vc = generateView()
        vc.messageType = .paymentCard
        vc.store = PaymentStore(channelId: channelId)
        vc.store.shouldSavePaymentPlan = vc.shouldSavePaymentPlan ?? false
        vc.initalizeView()
        return vc
    }

    class func generateView() -> CreatePaymentViewController {
        let array = FuguFlowManager.bundle?.loadNibNamed("CreatePaymentViewController", owner: self, options: nil)
        let view: CreatePaymentViewController? = array?.first as? CreatePaymentViewController
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
//        let view = storyboard.instantiateViewController(withIdentifier: "CreatePaymentViewController") as! CreatePaymentViewController

        guard let customView = view else {
            let vc = CreatePaymentViewController()
            return vc
        }
//        return view
        return customView
    }
    
    class func get(store: PaymentStore) -> CreatePaymentViewController {
        let vc = generateView()
        vc.messageType = .none
        vc.store = store
        vc.shouldSavePaymentPlan = false
        vc.initalizeView()
        return vc
    }
    

    class func get(store: PaymentStore, shouldSavePlan: Bool = false) -> CreatePaymentViewController {
        let vc = generateView()
        vc.messageType = .paymentCard
        vc.store = store
        vc.shouldSavePaymentPlan = shouldSavePlan
        vc.initalizeView()
        return vc
    }
    
    func startLoaderAnimation() {
        DispatchQueue.main.async {
            self.loaderView?.startRotationAnimation()
        }
    }
    
    func stopLoaderAnimation() {
        DispatchQueue.main.async {
            self.loaderView?.stopRotationAnimation()
        }
    }
    
}
extension CreatePaymentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIView.tableAutoDimensionHeight
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
        if self.messageType == .paymentCard{
            if let errorMesaage = store.validateStore() {
                showAlert(title: "", message: errorMesaage, actionComplete: nil)
                return
            }
//        delegate?.sendMessage(for: store)
            self.startLoaderAnimation()
            store.takeAction {[weak self] (success, error) in
                self?.stopLoaderAnimation()
                guard success else {
                    showAlertWith(message: error?.localizedDescription ?? "", action: nil)
                    return
                }
                if self?.store.isSending ?? false && !(self?.store.canEditPlan ?? false){
                    self?.delegate?.paymentCardPayment(isSuccessful: true)
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    self?.delegate?.backButtonPressed(shouldUpdate: true)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }else{
            if let errorMesaage = store.validateStore() {
                showAlertWith(message: errorMesaage, action: nil)
                return
            }
            delegate?.sendMessage(for: store)
            self.navigationController?.popViewController(animated: true)
        }
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
    func itemPriceUpdated() {
        store.totalCost = store.getTotalPriceWithRequest(with: "").totalPrice
        store.totalPriceUpdated?()
    }
}


extension CreatePaymentViewController: ShowMoreTableViewCellDelegate {
    func savePaymentPlanClicked(shouldSavePlan: Bool) {
        self.shouldSavePaymentPlan = shouldSavePlan
        store.shouldSavePaymentPlan = shouldSavePlan
    }
    
    func buttonClicked(with form: PaymentField) {
        if let errorMesaage = store.validateStore() {
            showAlert(title: "", message: errorMesaage, actionComplete: nil)
            return
        }
        store.addNewItem()
    }
}

extension CreatePaymentViewController: PaymentStoreDelegate {
    func dataUpdate() {
        datasource?.shouldSavePaymentPlan = self.shouldSavePaymentPlan
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }
}

extension CreatePaymentViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
