//
//  RouterExtensions.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP

extension Router {
    func routeToAnalysis(text: String) {
        guard let viewController = UIStoryboard.main.instantiateViewController(withIdentifier: AnalysisViewController.Identifier) as? AnalysisViewController else { return }
        
        let presenter = AnalysisPresenter(router: self)
        
        presenter.view = viewController
        presenter.update(inputText: text)
        
        (viewController as AnalysisViewProtocol).presenter = presenter
            
        push(viewController)
    }
}
