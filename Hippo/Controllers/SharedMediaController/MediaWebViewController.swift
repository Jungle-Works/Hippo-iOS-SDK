//
//  MediaWebViewController.swift
//  HippoAgent
//
//  Created by Arohi Magotra on 07/04/21.
//  Copyright © 2021 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit
import WebKit


class MediaWebViewController: UIViewController {

    //MARK:- Variables
    var webView: WKWebView!
    var config: WebViewConfig!

    //MARK:- IBOutlets
    @IBOutlet private var viewNavigationBar : NavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        initalizeWebView()
        downloadAndSaveFile()
        // Do any additional setup after loading the view.
    }


    func downloadAndSaveFile() {
       // startLoading()

        let documentsPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path

        var documentUrl = URL.init(fileURLWithPath: documentsPath)
        documentUrl.appendPathComponent(config.title)
        //Create URL to the source file you want to download
        let fileURL = config.initalUrl
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: documentUrl.path) {
            self.launchRequest(documentUrl)
            return
        }
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url:fileURL)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
          //  stopLoading()
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: documentUrl)
                } catch (let writeError) {
                    HippoConfig.shared.log.debug(("Error creating a file \(documentUrl) : \(writeError)"), level: .error)
                }
                self.launchRequest(documentUrl)
            } else {
                HippoConfig.shared.log.debug(("Error took place while downloading a file. Error description: %@", error?.localizedDescription), level: .error)
            }
        }
        task.resume()

    }


    private func initalizeWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.ignoresViewportScaleLimits = false
        webView = WKWebView(frame: CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: self.view.frame.size.height - 50), configuration: webConfiguration)
        webView.uiDelegate = self
        if !config.zoomingEnabled {
            webView.scrollView.delegate = self
        }
        webView.navigationDelegate = self
        view = webView
    }

    private func launchRequest(_ url : URL) {
        let fileURL = URL(fileURLWithPath: url.path)
        DispatchQueue.main.async {
            self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        }
    }

    private func setTheme() {
        self.navigationController?.isNavigationBarHidden = true
        viewNavigationBar.title = config.title
        viewNavigationBar.leftButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        
    }
    private func doesFileExistsAt(filePath: String) -> Bool {
        return (try? Data(contentsOf: URL(fileURLWithPath: filePath))) != nil
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension MediaWebViewController {
    class func getNewInstance(config: WebViewConfig) -> MediaWebViewController {
        let storyboard = UIStoryboard(name: "AgentSdk", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "MediaWebViewController") as! MediaWebViewController
        vc.config = config
        return vc
    }
}
extension MediaWebViewController: WKUIDelegate {

}
extension MediaWebViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = config.zoomingEnabled
    }
}
extension MediaWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("======00000\(webView.url?.description ?? "")")
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
