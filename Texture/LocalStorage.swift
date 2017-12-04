//
//  LocalStorage.swift
//  Texture
//
//  Created by Halil Gursoy on 04.12.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

protocol LocalStorageProtocol {
    func getSavedArticles() -> [Article]
    func save(_ article: Article) -> Bool
}

class LocalStorage: LocalStorageProtocol {
    private let savedArticlesKey = "savedArticles"
    
    private lazy var savedArticlesPath: String = {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentURL!.appendingPathComponent(savedArticlesKey).path
    }()
    
    private lazy var currentSavedArticles: [Article] = {
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: savedArticlesPath) as? Data,
            let articles = try? JSONDecoder().decode([Article].self, from: data)
        else { return [] }
        
        return articles
    }()
    
    func getSavedArticles() -> [Article] {
        return currentSavedArticles
    }
    
    @discardableResult
    func save(_ article: Article) -> Bool {
        currentSavedArticles.append(article)
        return save(articles: currentSavedArticles)
    }
    
    @discardableResult
    private func save(articles: [Article]) -> Bool {
        guard let jsonData = try? JSONEncoder().encode(articles) else { return false }
        
        NSKeyedArchiver.archiveRootObject(jsonData, toFile: savedArticlesPath)
        return true
    }
}
