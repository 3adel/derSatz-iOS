//
//  SavedPresenters.swift
//  Texture
//
//  Created by Halil Gursoy on 18.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP

class SavedPresenter: Presenter, SavedPresenterProtocol {
    
    var savedView: SavedViewProtocol? {
        return view as? SavedViewProtocol
    }
    
    let dataStore = DataStore()
    
    var savedArticles: [Article] = []
    
    override func getInitialData() {
        dataStore.getSavedArticles() { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let articles):
                self.savedArticles = articles
                let viewModels = articles.map(self.makeSavedViewModel)
                self.savedView?.render(with: viewModels)
            case .failure(_):
                self.view?.show(errorMessage: "Something went wrong")
            }
        }
    }
    
    func didTapOnArticle(at index: Int) {
        let article = savedArticles[index]
        router?.routeToAnalysis(input: .article(article))
    }
    
    func didTapDeleteForArticle(at index: Int, completionHandler: @escaping (Bool) -> Void) {
        let article = savedArticles[index]
        dataStore.deleteSavedArticle(article) { [weak self] result in
            guard let `self` = self else { return }
            
            let success = result.value != nil
            if success {
                self.savedArticles.remove(at: index)
                let viewModels = self.savedArticles.map(self.makeSavedViewModel)
                self.savedView?.update(viewModels: viewModels)
            }
            completionHandler(success)
        }
    }
    
    private func makeSavedViewModel(from article: Article) -> SavedArticleViewModel {
        let title = !article.title.isEmpty ? article.title : article.body
        let source: String?
        
        switch article.source {
        case .freeText:
            source = nil
        case .internet:
            source = article.url?.absoluteString
        }
        
        return SavedArticleViewModel(title: title, source: source, imageURL: article.topImageURL)
    }
}
