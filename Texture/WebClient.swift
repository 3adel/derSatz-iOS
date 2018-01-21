//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Alamofire


public enum ServerErrorUserInfoKey: String {
    case Error
    case Request
    case Response
    
    public var key: String {
        return self.rawValue
    }
}

public enum ContentType: String {
    case applicationJson = "application/json"
    case applicationFormUrlEncoded = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data"
    case textHtml = "text/html"
    case imagePng = "image/png"
    
    public static var header: String {
        return "Content-Type"
    }
}

typealias APIResultHandler = (AnyAPIResult) -> Void

class WebClient {
    
    static let RequestTimeOut: TimeInterval = 60
    
    let manager: Alamofire.SessionManager
    
    var reachabilityManager: NetworkReachabilityManager?
    var reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus?
    
    var cancelledRequests: [URLRequest] = []
    
    init(manager: Alamofire.SessionManager? = nil) {
        self.manager = manager ?? Alamofire.SessionManager.default
    }
    
    func createRequest<T: API>(api: T, endpoint: APIEndpoint, ids: [Token:String]? = nil, queryItems: [URLQueryItem]? = nil, json: Data? = nil, method: HTTPMethod = .GET, cache: Bool = false) -> URLRequest? {
        
        guard let fullURLString = api.generateURLString(from: endpoint, ids: ids, queryItems: queryItems),
            let url = URL(string: fullURLString)
            else { return nil }
        
        let cachePolicy: URLRequest.CachePolicy = cache ? .returnCacheDataElseLoad : .reloadIgnoringLocalAndRemoteCacheData
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: WebClient.RequestTimeOut)
        
        if let json = json {
            do {
                request.httpBody = json
                request.setValue(ContentType.applicationJson.rawValue, forHTTPHeaderField: ContentType.header)
            }
            catch {
                //FIX-IT: If JSON payload cannot be serialised, an error should be thrown
            }
        }
        request.httpMethod = method.rawValue
        return request
    }
    
    func send(_ request: URLRequest, cache: Bool = false, completion: APIResultHandler? = nil) {
        setupReachabilityManager(for: request.url?.host ?? "")
         
        removeRequestFromCancelled(request)
        
        manager.request(request)
            .validate()
            .responseJSON { alamofireResponse in
                guard !self.requestIsCancelled(alamofireResponse.request)
                    else {
                        self.removeRequestFromCancelled(alamofireResponse.request)
                        return
                }
                
                var result: AnyAPIResult!
                
                switch alamofireResponse.result {
                case .failure(_):
                    if let reachabilityStatus = self.reachabilityStatus,
                        reachabilityStatus == .notReachable || reachabilityStatus == .unknown {
                        result = .failure(APIError.networkUnavailable)
                    } else {
                        guard let statusCode = alamofireResponse.response?.statusCode
                            else {
                                result = .failure(APIError.genericNetworkError)
                                break
                        }
                        let error = APIError(statusCode: statusCode) ?? APIError.genericNetworkError
                        result = .failure(error)
                    }
                case .success(let value):
                    result = .success(value)
                }
                completion?(result)
        }
    }
    
    func requestIsCancelled(_ request: URLRequest?) -> Bool {
        var isCancelled = false
        
        for cancelledRequest in cancelledRequests {
            guard let request = request
                else { continue }
            
            isCancelled = request.url == cancelledRequest.url
            
            if isCancelled {
                break
            }
        }
        
        return isCancelled
    }
    
    func removeRequestFromCancelled(_ request: URLRequest?) {
        guard let request = request else { return }
        cancelledRequests.remove(request)
    }
    
    func cancelAllRequests(completion: @escaping () -> Void) {
        manager.session.getAllTasks { tasks in
            tasks.forEach { [weak self] in
                guard let strongSelf = self else { return }
                
                if let request = $0.currentRequest,
                    !strongSelf.cancelledRequests.contains(request) {
                    
                    strongSelf.cancelledRequests.append(request)
                }
                $0.cancel()
            }
            completion()
        }
    }
    
    func setupReachabilityManager(for host: String) {
        reachabilityManager?.stopListening()
        
        reachabilityManager = Alamofire.NetworkReachabilityManager(host: host)
        reachabilityManager?.listener = listenTo
        reachabilityManager?.startListening()
    }
    
    func listenTo(reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus) {
        self.reachabilityStatus = reachabilityStatus
    }
}

public enum HTTPMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

protocol URLRequestType {
    var url: URL? { get }
}

extension URLRequest: URLRequestType {}

extension Array where Element: URLRequestType {
    
    mutating func remove(_ request: URLRequestType) {
        var indexesToBeRemoved: [Int] = []
        
        self.enumerated().forEach {
            if $0.element.url == request.url {
                indexesToBeRemoved.append($0.offset)
            }
        }
        
        indexesToBeRemoved.forEach { remove(at: $0) }
    }
}

