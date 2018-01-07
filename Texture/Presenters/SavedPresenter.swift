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
            case .failure(let error):
                self.view?.show(errorMessage: "Something went wrong")
            }
        }
    }
    
    func didTapOnArticle(at index: Int) {
        let article = savedArticles[index]
        router?.routeToAnalysis(input: .article(article))
    }
    
    private func makeSavedViewModel(from article: Article) -> SavedArticleViewModel {
        let title = !article.title.isEmpty ? article.title : article.body
        return SavedArticleViewModel(title: title, imageURL: article.topImageURL)
    }
}
