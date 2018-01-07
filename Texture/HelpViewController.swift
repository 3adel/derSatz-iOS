//
//  HelpViewController.swift
//  Texture
//
//  Created by Halil Gursoy on 07.12.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import WebKit
import RVMP

class HelpViewController: UIViewController {
    var webView: WKWebView!
    
    var activityIndicator: UIActivityIndicatorView?
    
    var presenter: BasePresenter?
    var helpPresenter: HelpPresenterType? {
        return presenter as? HelpPresenterType
    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.snapToSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helpPresenter?.getInitialData()
        title = "Help"
        
    }
}

extension HelpViewController: HelpView {
    func render(with viewModel: HelpViewModel) {
        let request = URLRequest(url: viewModel.url)
        webView.load(request)
    }
}

extension HelpViewController: WebLoaderShowable {
    @objc func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator()
    }
    @objc func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideActivityIndicator()
    }
}
