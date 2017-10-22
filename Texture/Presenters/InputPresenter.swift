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
        guard let text = inputText else { return }
        
        if let _ = URL(string: text) {
            dataStore.getArticle(at: text) { [weak self] result in
                switch result {
                case .success(let article):
                    self?.router?.routeToAnalysis(article: article)
                default:
                    break
                }
            }
        } else {
            router?.routeToAnalysis(text: text)
        }
    }
}
