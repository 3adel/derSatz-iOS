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
    
    let genericErrorResult: AnyResult = .failure(APIError.genericNetworkError)
    
    func translate(_ sentence: String, to: Language, completion: @escaping (AnyResult) -> Void) {
        cancelAllOperations()
        
        let endpoint = Endpoint.translate
        
        let toLanguageQueryItem = URLQueryItem(name: "target", value: to.languageCode)
        
        let searchQueryItem = URLQueryItem(name: "q",
                                           value: sentence)
        
        guard let request = webClient.createRequest(endpoint: endpoint,
                                                    queryItems: [toLanguageQueryItem, searchQueryItem]) else {
                completion(genericErrorResult)
                return
        }
        
        send(request: request, endpoint: endpoint, completion: completion)
    }
    
    func translate(_ sentences: [String], to: Language, completion: @escaping (AnyResult) -> Void) {
        var postData: [String: Any] = ["q":  sentences, "target" : to.languageCode]
        
        let endpoint = Endpoint.translate
        
        guard let json = try? JSONSerialization.data(withJSONObject: postData, options: []),
            let request = webClient.createRequest(endpoint: endpoint,
                                                  json: json,
                                                  method: .POST) else {
                                                    completion(genericErrorResult)
                                                    return
        }
        
        send(request: request, endpoint: endpoint, completion: completion)
    }
    
    func cancelAllOperations() {
        webClient.cancellAllRequests()
    }
    
    func send(request: URLRequest, endpoint: Endpoint, completion: @escaping ResultHandler) {
        webClient.send(request, cache: false) { result in
            switch (result) {
            case .failure(let apiError):
                let appError = endpoint.appError(from: apiError)
                let result: AnyResult = .failure(appError)
                completion(result)
            case .success(let apiResult):
                let result = AnyResult(apiResult)
                completion(result)
            }
        }
    }
}

