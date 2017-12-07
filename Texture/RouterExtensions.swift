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
       routeToAnalysis(text: text, article: nil)
    }
    
    func routeToAnalysis(article: Article) {
        routeToAnalysis(text: nil, article: article)
    }
    
    func routeToLanguageSelection(languages: [Language], selectedLanguage: Language, languageType: LanguageType) {
        //TODO: Implementation
    }
    
    func routeToHelpSection() {
         guard let viewController = UIStoryboard.main.instantiateViewController(withIdentifier: HelpViewController.Identifier) as? HelpViewController else { return }
        
        let presenter = HelpPresenter(router: self)
        presenter.view = viewController
        
        viewController.presenter = presenter
        
        push(viewController)
    }
    
    private func routeToAnalysis(text: String?, article: Article?) {
        guard let viewController = UIStoryboard.main.instantiateViewController(withIdentifier: AnalysisViewController.Identifier) as? AnalysisViewController else { return }
        
        let presenter = AnalysisPresenter(router: self)
        presenter.view = viewController
        
        if let article = article {
            presenter.article = article
        } else if let text = text {
            presenter.update(inputText: text)
        }
        
        (viewController as AnalysisViewProtocol).presenter = presenter
        
        push(viewController)
    }
}
