//
//  PremiumMembershipPresenter.swift
//  Texture
//
//  Created by Halil Gursoy on 28.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import Foundation
import RVMP

class PremiumMembershipPresenter: Presenter, PremiumMembershipPresenterProtocol {
    var premiumMembershipView: PremiumMembershipViewProtocol? {
        return view as? PremiumMembershipViewProtocol
    }
    
    let iapService: IAPService
    
    var type: PremiumPopupType = .general
    
    required init(router: Router?) {
        iapService = .shared
        super.init(router: router)
    }
    
    init(iapService: IAPService = .shared) {
        self.iapService = iapService
    }
    
    override func getInitialData() {
        let title: String
        let body: NSAttributedString
        
        switch type {
        case .general:
            title = "Unlock Premium!"
            body = NSAttributedString(string: """
            Enjoy the following features for life:
            
                1. Bookmark analysed text snippets and articles.

                2. Analyse articles URLs directly from Safari through our app extension.

                3. Select text snippets and analyse them through our app extension.
            """)
        case .onFeatureUse(let daysLeft):
            title = "Premium Feature"
            let bodyString = """
            You are using one of our premium features! You can continue using it for \(daysLeft) more days.
            
            After that, you can purchase the premium membership and enjoy the following cool features for life:
            
                1. Bookmark analysed text snippets and articles.
            
                2. Analyse articles URLs directly from Safari through our app extension.
            
                3. Select text snippets and analyse them through our app extension.
            """
            let daysLeftRange = (bodyString as NSString).range(of: "\(daysLeft)")
            let bodyAttributedString = NSMutableAttributedString(string: bodyString)
            bodyAttributedString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .bold)], range: daysLeftRange)
            body = bodyAttributedString.attributedSubstring(from: bodyString.fullRange)
        }
        let demoViewModel = PremiumMembershipViewModel(title: title,
                                                       body: body,
                                                       buyButtonTitle: "Unlock Now for $7.99")
        
        premiumMembershipView?.render(with: demoViewModel)
    }
   
    func didTapBuyButton() {
        view?.showLoader()
        iapService.buy(product: DerSatzIAProduct.premium) { [weak self] result in
            switch result {
            case .success:
                self?.router?.show(infoMessage: "The purchase was successful!")
            case .error(let errorMessage):
                self?.router?.show(errorMessage: errorMessage)
            default: break
            }
            self?.view?.hideLoader()
            self?.router?.dismiss()
        }
    }
    
    func didTapRestorePurchaseButton() {
        view?.showLoader()
        iapService.restorePurchase(for: DerSatzIAProduct.premium) { [weak self] result in
            switch result {
            case .success:
                self?.router?.show(infoMessage: "Purchase restoration was successful")
            case .error(let errorMessage):
                self?.router?.show(errorMessage: errorMessage)
            default: break
            }
            self?.view?.hideLoader()
            self?.router?.dismiss()
        }
    }
}
