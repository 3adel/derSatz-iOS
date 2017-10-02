//
//  API.swift
//  Texture
//
//  Created by Halil Gursoy on 02.10.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

public typealias Token = String
public typealias Parameter = String

protocol API {
    associatedtype Endpoint: APIEndpoint
    var baseURI: String { get }
    var apiKey: String { get }
    
    func appError(from apiError: APIError, for endpoint: Endpoint) -> APIError
    func generateURLString(from endpoint: APIEndpoint, ids:[Token:String]?, queryItems: [URLQueryItem]?) -> String?
}

protocol APIEndpoint {
    var path: String { get }
    var endTokens: String { get }
}

extension RawRepresentable where RawValue == String, Self: APIEndpoint {
    var path: String {
        return rawValue
    }
}

extension API {
    func generateURLString(from endpoint: APIEndpoint, ids:[Token:String]?, queryItems: [URLQueryItem]?) -> String? {
        // convert baseURI string to NSURL to avoid cropping of protocol information:
        var baseURL = URL(string: baseURI)
        // appended path components will be URL encoded automatically:
        baseURL = baseURL!.appendingPathComponent(endpoint.path).appendingPathComponent("v2").appendingPathComponent(endpoint.endTokens)
        // re-decode URL components so token placeholders can be replaced later:
        var populatedEndPoint: String = baseURL!.absoluteString.removingPercentEncoding!
        
        if let replacements = ids {
            for (token, value) in replacements {
                populatedEndPoint = populatedEndPoint.replacingOccurrences(of: "{\(token)}", with: value)
            }
        }
        
        let  apiKeyQueryItem = URLQueryItem(name: "key", value: apiKey)
        var queryItemsWithAPIKey = [apiKeyQueryItem]
        
        if let queryItems = queryItems {
            queryItemsWithAPIKey.append(contentsOf: queryItems)
        }
        
        if var urlComponents = URLComponents(string: populatedEndPoint) {
            urlComponents.queryItems = queryItemsWithAPIKey
            return urlComponents.string ?? populatedEndPoint
        }
        return populatedEndPoint.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)
    }
}

private extension String {
    func stringByAppendingPathComponent(_ comp: String) -> String {
        return self + "/" + comp
    }
}
