//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

typealias AnyAPIResult = Result<Any, APIError>
typealias AnyResult = Result<Any, APIError>

typealias ResultHandler = (AnyResult) -> Void

class APIClient: DataClient {
    let webClient = WebClient()
    
    let googleAPI = GoogleAPI()
    let textAnalyzerAPI = TextAnalyzerAPI()
    
    let genericErrorResult: AnyResult = .failure(APIError.genericNetworkError)
    
    func translate(_ sentence: String, to: Language, completion: @escaping (AnyResult) -> Void) {
        cancelAllOperations()
        
        let toLanguageQueryItem = URLQueryItem(name: "target", value: to.languageCode)
        
        let searchQueryItem = URLQueryItem(name: "q",
                                           value: sentence)
        
        let endpoint = GoogleEndpoint.translate
        guard let request = webClient.createRequest(api: googleAPI, endpoint: endpoint,
                                                    queryItems: [toLanguageQueryItem, searchQueryItem],
                                                    cache: true) else {
                completion(genericErrorResult)
                return
        }
        
        send(request: request, api: googleAPI, endpoint: endpoint, completion: completion)
    }
    
    func translate(_ sentences: [String], to: Language, completion: @escaping (AnyResult) -> Void) {
        let postData: [String: Any] = ["q":  sentences, "target" : to.languageCode]
        
        let endpoint = GoogleEndpoint.translate
        
        guard let json = try? JSONSerialization.data(withJSONObject: postData, options: []),
            let request = webClient.createRequest(api: googleAPI, endpoint: endpoint,
                                                  json: json,
                                                  method: .POST,
                                                  cache: false) else {
                                                    completion(genericErrorResult)
                                                    return
        }
        
        send(request: request, api: googleAPI, endpoint: endpoint, completion: completion)
    }
    
    func getArticle(at url: String, completion: @escaping (AnyResult) -> Void) {
        let queryItem = URLQueryItem(name: "url", value: url)
        
        let endpoint = TextAnalyzerEndpoint.api
        guard let request = webClient.createRequest(api: textAnalyzerAPI, endpoint: endpoint, queryItems: [queryItem]) else { return }
        
        send(request: request, api: textAnalyzerAPI, endpoint: endpoint, completion: completion)
    }
    
    func cancelAllOperations() {
        webClient.cancellAllRequests()
    }
    
    func send<T: API>(request: URLRequest, api: T, endpoint: APIEndpoint, completion: @escaping ResultHandler) {
        guard let endpoint = endpoint as? T.Endpoint else { return }
        
        webClient.send(request, cache: false) { result in
            switch (result) {
            case .failure(let apiError):
                let appError = api.appError(from: apiError, for: endpoint)
                let result: AnyResult = .failure(appError)
                completion(result)
            case .success(let apiResult):
                let result = AnyResult(apiResult)
                completion(result)
            }
        }
    }
}

