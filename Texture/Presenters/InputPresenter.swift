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
    var inputText: String?
    
    func textInputDidChange(to text: String) {
        inputText = text
    }
    
    func didTapAnalyseButton() {
        guard let text = inputText else { return }
        router?.routeToAnalysis(text: text)
    }
}
