//
//  AppDelegate.swift
//  WKWebViewTest2
//
//  Created by bitu on 2019/4/4.
//  Copyright © 2019 bitu. All rights reserved.
//


import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView
    var authorsWebView: WKWebView?
    @IBOutlet weak var authorsButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var stopReloadButton: UIBarButtonItem!
    
    let MessageHandler = "didFetchAuthors"
    
    required init?(coder aDecoder: NSCoder) {
//        self.webView = WKWebView(frame: CGRect.zero)
        /**
         - mediaPlaybackRequiresUserAction to specify whether a video player starts playing automatically or requires a tap from the user
         - mediaPlaybackAllowsAirPlay to specify whether the video player can stream content to AirPlay supported devices
         - preferences, an instance of WKPreferences, which encapsulates further properties to configure the web view rendering like minimumFontSize and javascriptEnabled
         - userContentController which is the facilitator that enables injecting user scripts into web pages and listening for a callbacks
         **/
        
        
        let configuration = WKWebViewConfiguration()
    
        // 1
        let hideBioScriptURL = Bundle.main.path(forResource: "hideBio", ofType: "js")
        let hideBioJS = try! String(contentsOfFile: hideBioScriptURL!, encoding: String.Encoding.utf8)
        // 2
        let hideBioScript = WKUserScript(source: hideBioJS, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        // 3
        configuration.userContentController.addUserScript(hideBioScript)
        
        // 1
        let graphyScriptURL = Bundle.main.path(forResource: "biograpy", ofType: "js")
        let graphyJS = try! String(contentsOfFile: graphyScriptURL!, encoding: String.Encoding.utf8)
        // 2
        let graphyScript = WKUserScript(source: graphyJS, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        // 3
        configuration.userContentController.addUserScript(graphyScript)

        // 4
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        super.init(coder: aDecoder)
        self.webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorsButton.isEnabled = false
        backButton.isEnabled = false
        forwardButton.isEnabled = false;
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let top = webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        let leading = webView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailing = webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let bottom = webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44)
        view.addConstraints([top, leading, trailing, bottom])
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        let request = URLRequest(url: URL(string: "https://www.raywenderlich.com/u/funkyboy")!)
        webView.load(request)
        
        
        // authorWebView
        //1
        let authorsWebViewConfiguration = WKWebViewConfiguration() //2
        let scriptURL = Bundle.main.path(forResource: "fetchAuthors", ofType: "js")
        let jsScript = try! String(contentsOfFile: scriptURL!, encoding: String.Encoding.utf8)
        //3
        let fetchAuthorsScript = WKUserScript(source: jsScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        //4
        authorsWebViewConfiguration.userContentController.addUserScript(fetchAuthorsScript)
        //5
        authorsWebViewConfiguration.userContentController.add(self, name: MessageHandler)
        //6
        authorsWebView = WKWebView(frame: .zero, configuration: authorsWebViewConfiguration)
        //7
        let authorsRequest = URLRequest(url: URL(string: "http://www.raywenderlich.com/about")!)
        authorsWebView!.load(authorsRequest)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "loading") {
            forwardButton.isEnabled = webView.canGoForward
            backButton.isEnabled = webView.canGoBack
            stopReloadButton.image = webView.isLoading ? UIImage(named: "icon_stop") : UIImage(named: "icon_refresh")
            UIApplication.shared.isNetworkActivityIndicatorVisible = webView.isLoading
        } else if (keyPath == "title") {
            if (webView.url!.absoluteString.hasPrefix("https://www.raywenderlich.com/u")) {
//                title = webView.title!.stringByReplacingOccurrencesOfString("Ray Wenderlich | ", withString: "")
                title = webView.title?.replacingOccurrences(of: "Ray Wenderlich | ", with: "")
            }
        }
    }
    
    private func webView(webView: WKWebView!, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError!) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func webView(webView: WKWebView!, decidePolicyForNavigationAction navigationAction: WKNavigationAction!, decisionHandler: ((WKNavigationActionPolicy) -> Void)!) {
        if (navigationAction.navigationType == .linkActivated && !navigationAction.request.url!.host!.lowercased().hasPrefix("www.raywenderlich.com")) {
//            UIApplication.shared.openURL(navigationAction.request.url!);
            UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    @IBAction func authorsButtonTapped(sender: UIBarButtonItem) {
        print("Authors tapped")
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    
    @IBAction func goForward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func stopReload(sender: UIBarButtonItem) {
        if (webView.isLoading) {
            webView.stopLoading()
        } else {
            let request = URLRequest(url: webView.url!)
            webView.load(request)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("message is \(message.body)")
        if message.name == MessageHandler {
            if let resultArray = message.body as? [String: Any] {
                for d in resultArray {
                    print(d)
                }
            }
        }
    }
}

