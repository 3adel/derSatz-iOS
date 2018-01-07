//
//  RouterExtensions.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP

enum AnalysisInput {
    case text(String)
    case url(URL)
    case article(Article)
}

extension Router {
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
    
    func routeToAnalysis(input: AnalysisInput) {
        guard let viewController = UIStoryboard.main.instantiateViewController(withIdentifier: AnalysisViewController.Identifier) as? AnalysisViewController else { return }
        
        let presenter = AnalysisPresenter(router: self)
        presenter.view = viewController
        
        switch input {
        case .article(let article):
            presenter.article = article
        case .url(let url):
            presenter.update(inputURL: url)
        case .text(let text):
            presenter.update(inputText: text)
        }
        
        (viewController as AnalysisViewProtocol).presenter = presenter
        
        push(viewController)
    }
}
