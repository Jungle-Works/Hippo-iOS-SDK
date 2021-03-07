////
////  RazorPayViewController.swift
////  Pods
////
////  Created by Arohi Sharma on 05/11/20.
////
//
//import UIKit
//#if canImport(Razorpay)
//import Razorpay
//#endif
//#if canImport(Razorpay)
//class RazorPayViewController : UIView, RazorpayPaymentCompletionProtocol {
//
//
//    //MARK:- Variables
//    var razorpay: RazorpayCheckout!
//    var razorPayDic : RazorPayData?
//    var isPaymentSuccess : ((Bool)->())?
//    var isPaymentCancelled : ((Bool)->())?
//    
//    internal func showPaymentForm(_ viewController : UIViewController){
//        razorpay = RazorpayCheckout.initWithKey(razorPayDic?.apiKey ?? "", andDelegate: self)
//        let options: [String:Any] = [
//            "amount": razorPayDic?.amount ?? 0.0, //This is in currency subunits. 100 = 100 paise= INR 1.
//            "currency": razorPayDic?.currency ?? "",//We support more that 92 international currencies.
//            "description": razorPayDic?.description ?? "",
//            "order_id": razorPayDic?.orderId ?? "",
//            "prefill": [
//                "contact": razorPayDic?.phone,
//                "email": razorPayDic?.email
//            ],
//            "name": razorPayDic?.name ?? "",
//            "theme": [
//                "color": HippoConfig.shared.theme.themeColor.hippoToHexString()
//            ]
//                ]
//        razorpay.open(options, displayController: viewController)
//    }
//    
//
//    func onPaymentError(_ code: Int32, description str: String) {
//        if str == "Payment cancelled by user"{
//            isPaymentCancelled?(true)
//        }else{
//            isPaymentSuccess?(false)
//        }
//    }
//    
//    func onPaymentSuccess(_ payment_id: String) {
//        isPaymentSuccess?(true)
//    }
//}
//#endif
