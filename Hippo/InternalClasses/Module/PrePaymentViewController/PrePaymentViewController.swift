//
//  CheckoutViewController.swift
//  HippoChat
//
//  Created by Vishal on 05/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit
import WebKit

class PrePaymentViewController: UIViewController {
    
    @IBOutlet weak var navigationBar : NavigationBar!
    
    
    var webView: WKWebView!
    var config: WebViewConfig!
    var isComingForPayment = false
    var isPrePayment : Bool?
    var isPaymentSuccess : ((Bool)->())?
    var isPaymentCancelled : ((Bool)->())?
    var channelId : Int?
    let transparentView = UIView()
    var listener : SocketListner?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        initalizeWebView()
        launchRequest()
        
        navigationBar.title = config.title
        navigationBar.leftButton.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        navigationBar.image_back.isHidden = isPrePayment ?? false ? true : false
        navigationBar.leftButton.isEnabled = isPrePayment ?? false ? false : true
        navigationBar.rightButton.setImage(HippoConfig.shared.theme.crossBarButtonImage, for: .normal)
        navigationBar.rightButton.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        navigationBar.rightButton.isHidden = isPrePayment ?? false ? false : true
        navigationBar.rightButton.isEnabled = isPrePayment ?? false ? true : false
        navigationBar.rightButton.tintColor = .black
        SocketClient.shared.subscribeSocketChannel(channel: "\(channelId ?? -1)")
        listener = SocketListner()
        listener?.startListening(event: SocketEvent.SERVER_PUSH.rawValue, callback: { (data) in
            if let messageDict = data as? [String : Any]{
                if messageDict["message_type"] as? Int == 22{
                    if (messageDict["custom_action"] as? NSDictionary)?.value(forKey: "selected_id") as? Int == 1{
                        self.isPaymentSuccess?(true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            self.backAction(UIButton())
                        })
                        SocketClient.shared.unsubscribeSocketChannel(fromChannelId: "\(self.channelId ?? -1)")
                    }
                }
            }
        })
    }
    
    private func initalizeWebView() {
        let webConfiguration = WKWebViewConfiguration()
        if #available(iOS 10.0, *) {
            webConfiguration.ignoresViewportScaleLimits = false
        }
        var height : CGFloat = 0.0
        if #available(iOS 11.0, *) {
            height = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0.0
        }
        
        webView = WKWebView(frame: CGRect(x: 0, y: height + navigationBar.frame.size.height + 10, width: self.view.bounds.width, height: self.view.bounds.height - (height + navigationBar.frame.size.height + 10)), configuration: webConfiguration)
        webView.uiDelegate = self
        if !config.zoomingEnabled {
            webView.scrollView.delegate = self
        }
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    private func launchRequest() {
        let request = URLRequest(url: config.initalUrl)
        webView.load(request)
    }
    
    private func setTheme() {
        
    }
    
    class func getNewInstance(config: WebViewConfig) -> PrePaymentViewController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "CheckoutViewController") as! PrePaymentViewController
        vc.config = config
        return vc
    }
    
    // handling keys of paytm add money feature
    func handleForPaytmAddMoneyStatus(webUrl: String) {
        handleForUrlKeys(webUrl: webUrl)
    }
    
    //Payfort redirects through several URLs.
    func handleForUrlKeys(webUrl: String) {
        print(webUrl)
        if webUrl.contains("success.html") || webUrl.contains("Success"){
            self.isPaymentSuccess?(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.backAction(UIButton())
            })
        }else if webUrl.contains("error.html") || webUrl.contains("error") || webUrl.contains("Error"){
            self.isPaymentSuccess?(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.backAction(UIButton())
            })
        }
    }
    
    
    @IBAction func cancelAction(_ sender : UIButton){
        addTransparentView()
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            HippoConfig.shared.notifiyDeinit()
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        listener = nil
    }
}
extension PrePaymentViewController{
    func addTransparentView(){
      
        let window = UIApplication.shared.keyWindow
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let screenSize = UIScreen.main.bounds.size
        transparentView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        window?.addSubview(transparentView)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.openCancelPopup()
        }, completion: nil)
    }
   
    func openCancelPopup(){
        let bottomPopupController = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle).instantiateViewController(withIdentifier: "BottomPopupController") as! BottomPopupController
        bottomPopupController.modalPresentationStyle = .overFullScreen
        bottomPopupController.paymentCancelled = {[weak self]() in
            DispatchQueue.main.async {
                self?.isPaymentCancelled?(false)
                self?.onClickTransparentView()
                self?.backAction(UIButton())
            }
        }
        bottomPopupController.popupdismissed = {[weak self]() in
            DispatchQueue.main.async {
                self?.onClickTransparentView()
            }
        }
        self.present(bottomPopupController, animated: true, completion: nil)
    }
    @objc func onClickTransparentView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
        }, completion: { (status) in
            self.transparentView.removeFromSuperview()
        })
    }
    
}



extension PrePaymentViewController: WKUIDelegate {
    
}

extension PrePaymentViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = config.zoomingEnabled
    }
}

extension PrePaymentViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("======00000\(webView.url?.description ?? "")")
        if isComingForPayment == true{
            handleForPaytmAddMoneyStatus(webUrl: webView.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("======11111\(error)")
    }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("======22222\(webView)")
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("======33333\(navigation.debugDescription) \(webView.url?.description ?? "")")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("======44444\(error)")
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("======66666\(navigationAction)")
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("======55555\(navigationResponse)")
        decisionHandler(.allow)
    }
}

