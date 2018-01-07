//
//  RouterGenericExtensions.swift
//  Texture
//
//  Created by Halil Gursoy on 07.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import Foundation
import RVMP

extension Router {
    func routeToWebView(url: URL) {
        let webViewController = WebViewController()
        webViewController.url = url
        present(webViewController, embedInNavigationController: true)
    }
}
