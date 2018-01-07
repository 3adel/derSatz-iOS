//
//  LoaderShowable.swift
//  Texture
//
//  Created by Halil Gursoy on 07.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import UIKit
import WebKit

protocol WebLoaderShowable: WKNavigationDelegate  {
    var activityIndicator: UIActivityIndicatorView?  { get set }
    var view: UIView! { get set }
    func showActivityIndicator()
    func hideActivityIndicator()
}

extension WebLoaderShowable where Self: UIViewController {
    func showActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(activityIndicator!)
        activityIndicator?.centerInSuperview()
        activityIndicator?.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator?.stopAnimating()
    }
}
