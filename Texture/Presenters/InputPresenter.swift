//
//  InputPresenter.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP

class InputPresenter: Presenter, InputPresenterProtocol {
    let dataStore = DataStore()
    
    var inputText: String?
    
    func textInputDidChange(to text: String) {
        inputText = text
    }
    
    func didTapAnalyseButton() {
        guard let text = inputText,
            !text.isEmpty
            else {
                view?.show(errorMessage: "Text input cannot be empty")
                return
        }
        
        if let urlText = text.replacingOccurrences(of: " ", with: "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlText),
            UIApplication.shared.canOpenURL(url) {
            
            FeatureConfig.shared.didUse(.urlSearch)
            
            switch FeatureConfig.shared.status(for: .urlSearch) {
            case .disabled(let errorMessage):
                view?.show(errorMessage: errorMessage)
                return
            case .trial(let daysLeft):
                guard FeatureConfig.shared.shouldShowPromotion(for: .urlSearch) else { break }
                router?.showPremiumPopup(daysLeft: daysLeft) { [weak self] in
                    self?.router?.routeToAnalysis(input: .url(url))
                }
                FeatureConfig.shared.didShowPromotion(for: .urlSearch)
                return
            default: break
            }
            
            router?.routeToAnalysis(input: .url(url))
        } else {
            router?.routeToAnalysis(input: .text(text))
        }
    }
}
