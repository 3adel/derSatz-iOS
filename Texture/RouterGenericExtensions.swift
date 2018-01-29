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
    
    func showPremiumPopup(daysLeft: Int, completion: (() -> Void)? = nil) {
        guard let viewController = UIStoryboard.main.instantiateViewController(withIdentifier: PremiumMembershipViewController.Identifier) as? PremiumMembershipViewController else { return }
        viewController.daysLeft = daysLeft
        
        presentInPopup(viewController: viewController, completion: completion)
    }
    
    public func presentInPopup(viewController: UIViewController, sourceView: UIView? = nil, sourceRect: CGRect? = nil, completion: (() -> Void)? = nil) {
        let popupViewController = PopupViewController()
        popupViewController.embed(viewController: viewController)
        popupViewController.completion = completion
        
        
        present(sheetViewController: popupViewController, sourceView: sourceView, sourceRect: sourceRect, modalPresentationStyle: .overCurrentContext, animated: false)
    }
}
