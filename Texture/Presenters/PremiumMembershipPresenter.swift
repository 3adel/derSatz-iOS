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
    
    required init(router: Router?) {
        iapService = .shared
        super.init(router: router)
    }
    
    init(iapService: IAPService = .shared) {
        self.iapService = iapService
    }
   
    func didTapBuyButton() {
        iapService.buy(product: DerSatzIAProduct.premium) { [weak self] result in
            switch result {
            case .success:
                self?.router?.show(infoMessage: "The purchase was successful!")
            case .error(let errorMessage):
                self?.router?.show(errorMessage: errorMessage)
            default: break
            }
            self?.router?.dismiss()
        }
    }
}
