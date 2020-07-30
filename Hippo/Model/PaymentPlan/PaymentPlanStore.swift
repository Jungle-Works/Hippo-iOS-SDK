//
//  PaymentPlanStore.swift
//  HippoAgent
//
//  Created by Vishal on 05/12/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import Foundation
import UIKit

class PaymentPlanStore {
    var plans: [PaymentPlan] = [] {
        didSet {
            delegate?.plansUpdated()
        }
    }
    weak var delegate: PaymentPlansViewDelegate?
    
    init() {
        getPlans()
    }
    
    func getPlans() {
        guard let param = generateParam() else {
//            showAlert(title: "", message: "Something went wrong", actionComplete: nil)
            showAlertWith(message: HippoStrings.somethingWentWrong, action: nil)
            return
        }
//        HTTPRequest.init(method: .post, path: EndPoints.getPaymentPlans, parameters: param, encoding: .json, files: nil)
//            .config(isIndicatorEnable: true, isAlertEnable: true)
//            .handler { (response) in
//                guard let value = response.value as? [String: Any], let data = value["data"] as? [[String: Any]] else {
//                    return
//                }
//                let plans = PaymentPlan.parse(plans: data)
//                self.plans = plans
//        }
        
//        delegate?.startLoaderAnimation()
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: param, extendedUrl: AgentEndPoints.getPaymentPlans.rawValue) { (response, error, _, statusCode) in
            
//            self.delegate?.stopLoaderAnimation()
            
            guard let responseDict = response as? [String: Any],
                let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 else {
                    HippoConfig.shared.log.debug("API_GetPaymentPlans ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    getLastVisibleController()?.showAlert(title: "", message: (error?.localizedDescription ?? ""), buttonTitle: HippoStrings.ok, completion: nil)
                    self.delegate?.plansUpdated()
                    //                    completion(false, error)
                    return
            }
//            completion(true, nil)
            
//            guard let value = response.value as? [String: Any], let data = value["data"] as? [[String: Any]] else {
//                return
//            }
            guard let data = responseDict["data"] as? [[String: Any]] else {
                return
            }
            let plans = PaymentPlan.parse(plans: data)
            self.plans = plans
            
        }
        
    }
    
    func generateParam() -> [String: Any]? {
//        guard let access_token = PersonInfo.getAccessToken() else {
//            return nil
//        }
        guard let access_token = HippoConfig.shared.agentDetail?.fuguToken else {
            return nil
        }
        
        let param: [String: Any] = ["access_token": access_token,
                                    "type_array": HippoProperty.current.paymentPlanType]
        
        return param
    }
}
