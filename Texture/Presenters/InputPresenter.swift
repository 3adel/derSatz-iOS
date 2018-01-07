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
        dataStore.getSavedArticles() { result in
            switch result {
            case .success(let articles):
                print(articles)
            default:
                break
            }
        }
        guard let text = inputText,
            !text.isEmpty
            else {
                view?.show(errorMessage: "Text input cannot be empty")
                return
        }
        
        if let urlText = text.replacingOccurrences(of: " ", with: "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlText),
            UIApplication.shared.canOpenURL(url) {
            router?.routeToAnalysis(input: .url(url))
        } else {
            router?.routeToAnalysis(input: .text(text))
        }
    }
}
