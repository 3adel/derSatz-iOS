//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

class DataStore {
    private static let defaultClient = APIClient()
    
    private let dataClient: DataClient
    private let localStorage: LocalStorageProtocol
    
    init(dataClient: DataClient? = nil, localStorage: LocalStorageProtocol? = nil) {
        self.dataClient = dataClient ?? DataStore.defaultClient
        self.localStorage = localStorage ?? LocalStorage.shared
    }
    
    func getTranslation(of sentence: String, for toLanguage: Language, completion: @escaping (Result<Translation, APIError>) -> Void) {
        dataClient.translate(sentence, to: toLanguage) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                guard let dict = value as? JSONDictionary,
                let data = dict["data"] as? JSONDictionary,
                let translations = data["translations"] as? JSONArray,
                let translationDict = translations.first as? JSONDictionary,
                    let translation = Translation(with: translationDict) else {
                        completion(.failure(APIError.genericNetworkError))
                        return
                }
                
                completion(.success(translation))
            }
        }
    }
    
    func getTranslation(of sentences: [String], to language: Language, completion: @escaping(Result<[Translation], APIError>) -> Void) {
        dataClient.translate(sentences, to: language) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                guard let dict = value as? JSONDictionary,
                    let data = dict["data"] as? JSONDictionary,
                    let translationTexts = data["translations"] as? [JSONDictionary] else {
                        completion(.failure(APIError.genericNetworkError))
                        return
                }
                
                let translations: [Translation] = ModelFactory.arrayOf(translationTexts)
                completion(.success(translations))
            }
        }
    }
    
    func getArticle(at url: URL, completion: @escaping (Result<Article, APIError>) -> Void) {
        dataClient.getArticle(at: url.absoluteString) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                guard let dict = value as? JSONDictionary,
                    var article = Article(with: dict) else {
                        completion(.failure(APIError.genericNetworkError))
                        return
                }
                article.url = url
                completion(.success(article))
            }
        }
    }
    
    func getSavedArticles(completion: @escaping (Result<[Article], APIError>) -> Void) {
        let articles = localStorage.getSavedArticles()
        completion(.success(articles))
    }
    
    func save(_ article: Article, completion: @escaping (Result<Bool, APIError>) -> Void) {
        let didSave = localStorage.save(article)
        
        if didSave {
            completion(.success(true))
        } else {
            completion(.failure(.genericNetworkError))
        }
    }
    
    func deleteSavedArticle(_ article: Article, completion: @escaping (Result<Bool, APIError>) -> Void) {
        let didDelete = localStorage.delete(article)
        
        if didDelete {
            completion(.success(true))
        } else {
            completion(.failure(.genericNetworkError))
        }
    }
    
    func isArticleSaved(_ article: Article, completion: @escaping (Result<Bool, APIError>) -> Void) {
        let isSaved = localStorage.getSavedArticles().contains(article)
        
        completion(.success(isSaved))
    }
}
