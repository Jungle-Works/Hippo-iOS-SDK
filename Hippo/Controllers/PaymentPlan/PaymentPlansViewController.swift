//
//  PaymentPlansViewController.swift
//  HippoAgent
//
//  Created by Vishal on 05/12/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol PaymentPlansViewDelegate: class {
    func plansUpdated()
//    func startLoaderAnimation()
//    func stopLoaderAnimation()
}

protocol paymentCardPaymentOfCreatePaymentDelegate: AnyObject {
    func paymentCardPaymentOfCreatePayment(isSuccessful: Bool)
}

class PaymentPlansViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loaderView: So_UIImageView!
    
    var datasource = PaymentPlansDataSource()
    let store = PaymentPlanStore()
    var channelId: UInt?
    weak var sendNewPaymentDelegate: paymentCardPaymentOfCreatePaymentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        setTableView()
        self.startLoaderAnimation()
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    internal func setTheme() {
        store.delegate = self
//        setupCustomThemeOnNavigationBar(hideNavigationBar: false)
        self.navigationController?.setTheme()
        title = HippoStrings.savedPlans
        cancelButton.tintColor = HippoConfig.shared.theme.headerTextColor
//        self.view.backgroundColor = HippoTheme.theme.systemBackgroundColor.secondary
        loaderView.tintColor = HippoConfig.shared.theme.headerTextColor
    }
    
    internal func setTableView() {
        registerCell()
        tableView.tableFooterView = UIView()
        datasource.plans = store.plans
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        tableView.dataSource = datasource
        tableView.delegate = self
        setaddIcon()
    }
    
    internal func setaddIcon() {
        let button: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        button.tintColor = HippoConfig.shared.theme.headerTextColor
        navigationItem.rightBarButtonItem = button
    }
    @objc internal func addButtonClicked() {
        pushCreatePayment(with: nil, animated: true)
    }
    
    internal func registerCell() {
//        tableView.register(UINib(nibName: "PaymentPlanHomeCell", bundle: nil), forCellReuseIdentifier: "PaymentPlanHomeCell")
        let bundle = FuguFlowManager.bundle
        tableView.register(UINib(nibName: "PaymentPlanHomeCell", bundle: bundle), forCellReuseIdentifier: "PaymentPlanHomeCell")
        
    }
    
    class func get(channelId: UInt?) -> PaymentPlansViewController {
        let vc = generateView()
        vc.channelId = channelId
        return vc
    }
    
    class func generateView() -> PaymentPlansViewController {
        let array = FuguFlowManager.bundle?.loadNibNamed("PaymentPlansViewController", owner: self, options: nil)
        let view: PaymentPlansViewController? = array?.first as? PaymentPlansViewController
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
//        let view = storyboard.instantiateViewController(withIdentifier: "PaymentPlansViewController") as! PaymentPlansViewController
        
        guard let customView = view else {
            let vc = PaymentPlansViewController()
            return vc
        }
//        return view
        return customView
    }
    internal func pushCreatePayment(with plan: PaymentPlan?, animated: Bool) {
        let paymentStore = PaymentStore(plan: plan, channelId: channelId, isEditing: (plan == nil || channelId != nil), isSending: channelId != nil)
        let vc = CreatePaymentViewController.get(store: paymentStore)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: animated)
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
extension PaymentPlansViewController: PaymentPlansViewDelegate {
    
    func plansUpdated() {
        let plans = store.plans
        
        self.stopLoaderAnimation()
        
        if plans.isEmpty, channelId != nil {
            pushCreatePayment(with: nil, animated: false)
        }
        datasource.plans = plans
        tableView.reloadData()
    }
    
}
extension PaymentPlansViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let plans = store.plans
        let plan = plans[indexPath.row]
        
        pushCreatePayment(with: plan, animated: true)
    }
}
extension PaymentPlansViewController: CreatePaymentDelegate {
    func sendMessage(for store: PaymentStore) {
        //code
        print("")
    }
    func backButtonPressed(shouldUpdate: Bool) {
        if channelId != nil, store.plans.isEmpty {
            self.dismiss(animated: true, completion: nil)
            return
        }
        if shouldUpdate {
            store.getPlans()
        }
    }
    func paymentCardPayment(isSuccessful: Bool){
        if isSuccessful == true{
            self.sendNewPaymentDelegate?.paymentCardPaymentOfCreatePayment(isSuccessful: true)
        }
    }
}
