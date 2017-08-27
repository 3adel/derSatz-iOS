//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

class DataStore {
    private static let defaultClient = APIClient()
    
    private let dataClient: DataClient
    
    init(dataClient: DataClient? = nil) {
        self.dataClient = dataClient ?? DataStore.defaultClient
    }
    
    func getTranslation(of sentence: String, for toLanguage: Language, completion: @escaping (Result<String, APIError>) -> Void) {
        dataClient.translate(sentence, to: toLanguage) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                guard let dict = value as? JSONDictionary,
                let data = dict["data"] as? JSONDictionary,
                let translations = data["translations"] as? JSONArray,
                let translation = translations.first as? JSONDictionary,
                let translatedText = translation["translatedText"] as? String else {
                        completion(.failure(APIError.genericNetworkError))
                        return
                }
                
                completion(.success(translatedText))
            }
            
        }
    }
    
    func cancelPreviousSearches() {
        dataClient.cancelAllOperations()
    }
}


