//
//  RazorPayVC.swift
//  Hippo
//
//  Created by soc-admin on 25/05/22.
//

import UIKit
import Razorpay

class RazorPayVC: UIViewController {
    
    var razorpay: RazorpayCheckout!
    var paymentDict: RazorPayData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        razorpay = RazorpayCheckout.initWithKey(paymentDict.apiKey ?? "", andDelegate: self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showPaymentForm()
    }
    
    internal func showPaymentForm(){
        //        let options: [String:Any] = [
        //            "amount": "100", //This is in currency subunits. 100 = 100 paise= INR 1.
        //            "currency": "INR",//We support more that 92 international currencies.
        //            "description": "purchase description",
        //            "order_id": paymentDict.orderId ?? "",
        //            "image": "https://url-to-image.png",
        //            "name": "business or product name",
        //            "prefill": [
        //                "contact": "9797979797",
        //                "email": "foo@bar.com"
        //            ],
        //            "theme": [
        //                "color": "#F37254"
        //            ]
        //        ]
        var options = RazorPayData().getRaw(from: paymentDict)
        options["prefill"] = [
            "contact": HippoConfig.shared.userDetail?.phoneNumber ?? "",
            "email": HippoConfig.shared.userDetail?.email ?? ""
        ]
        options["theme"] = [
            "color": HippoConfig.shared.theme.themeColor.hippoToHexString()
        ]
        
        razorpay.open(options, displayController: self)
    }
}

extension RazorPayVC: RazorpayPaymentCompletionProtocol{
    func onPaymentError(_ code: Int32, description str: String) {
        if code == 2{
            HippoConfig.shared.HippoPrePaymentCancelled?()
        }else{
            HippoConfig.shared.HippoPrePaymentSuccessful?(false)
        }
        closeRazorPay()
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        HippoConfig.shared.HippoPrePaymentSuccessful?(true)
        closeRazorPay()
    }
    
    func closeRazorPay(){
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            HippoConfig.shared.notifiyDeinit()
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}
