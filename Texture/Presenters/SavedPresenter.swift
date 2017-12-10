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
    
    override func getInitialData() {
        let savedViewModels: [SavedArticleViewModel] = [
            SavedArticleViewModel(title: "Borussia Dortmund trennt sich von Trainer Peter Bosz und beruft Peter Stöger", imageURL: URL(string: "http://www.dw.com/image/41731820_303.jpg")),
            SavedArticleViewModel(title: "Jüngere CDU-Politiker denken über unionsgeführte Minderheitsregierung nach", imageURL: URL(string: "http://www.dw.com/image/41731568_303.jpg")),
            SavedArticleViewModel(title: "Borussia Dortmund trennt sich von Trainer Peter Bosz und beruft Peter Stöger", imageURL: nil)
        ]
        savedView?.render(with: savedViewModels)
    }
    
    func didTapOnArticle(at index: Int) {
        print("tapped on article at index \(index)")
    }
}
