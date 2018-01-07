//
//  File.swift
//  Texture
//
//  Created by Halil Gursoy on 07.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    private var webView = WKWebView()
    
    var url: URL?
    var activityIndicator: UIActivityIndicatorView?
    
    override func loadView() {
        view = webView
        webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WebLoaderShowable {
    @objc func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator()
    }
    @objc func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideActivityIndicator()
    }
}
