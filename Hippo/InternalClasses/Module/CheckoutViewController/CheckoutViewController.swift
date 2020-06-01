//
//  CheckoutViewController.swift
//  HippoChat
//
//  Created by Vishal on 05/11/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit
import WebKit

class CheckoutViewController: UIViewController {
    
    @IBOutlet weak var navigationBar : NavigationBar!
 
    
    var webView: WKWebView!
    var config: WebViewConfig!
    var isComingForPayment = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        initalizeWebView()
        launchRequest()
        
        navigationBar.title = config.title
        navigationBar.leftButton.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
      
    }
    
    private func initalizeWebView() {
        let webConfiguration = WKWebViewConfiguration()
        if #available(iOS 10.0, *) {
            webConfiguration.ignoresViewportScaleLimits = false
        }
        webView = WKWebView(frame: CGRect(x: 0, y: 60, width: self.view.bounds.width, height: self.view.bounds.height - 60), configuration: webConfiguration)
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
       
    class func getNewInstance(config: WebViewConfig) -> CheckoutViewController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "CheckoutViewController") as! CheckoutViewController
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
        if webUrl.contains("success.html"){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.backAction(UIButton())
            })
        }else if webUrl.contains("error.html") || webUrl.contains("error") || webUrl.contains("Error"){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.backAction(UIButton())
            })
        }
    }

    @IBAction func backAction(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: false)
    }

}
extension CheckoutViewController: WKUIDelegate {
    
}

extension CheckoutViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = config.zoomingEnabled
    }
}

extension CheckoutViewController: WKNavigationDelegate {
    
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
