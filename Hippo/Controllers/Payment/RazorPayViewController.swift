//
//  RazorPayViewController.swift
//  Pods
//
//  Created by Arohi Sharma on 05/11/20.
//

import UIKit
import Razorpay

class RazorPayViewController : UIView, RazorpayPaymentCompletionProtocol {

    //MARK:- IBOutlets
    @IBOutlet weak var view_NavBar :NavigationBar!
    
    //MARK:- Variables
    var razorpay: RazorpayCheckout!
    var razorPayDic : RazorPayData?
    
   
    
    internal func showPaymentForm(_ viewController : UIViewController){
        razorpay = RazorpayCheckout.initWithKey(razorPayDic?.apiKey ?? "", andDelegate: self)
        let options: [String:Any] = [
            "amount": razorPayDic?.amount ?? 0.0, //This is in currency subunits. 100 = 100 paise= INR 1.
            "currency": razorPayDic?.currency ?? "",//We support more that 92 international currencies.
            "description": razorPayDic?.description ?? "",
            "order_id": razorPayDic?.orderId ?? ""
                ]
        razorpay.open(options, displayController: viewController)
    }
    

    func onPaymentError(_ code: Int32, description str: String) {
        
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        
    }
}
