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
    
    var genericQueryItems: [URLQueryItem] { get }
    
    func appError(from apiError: APIError, for endpoint: Endpoint) -> APIError
    func generateURLString(from endpoint: APIEndpoint, ids:[Token:String]?, queryItems: [URLQueryItem]?) -> String?
    func appendGenericPathComponents(to url: URL) -> URL
}

protocol APIEndpoint {
    var path: String { get }
    var endTokens: String? { get }
}

extension RawRepresentable where RawValue == String, Self: APIEndpoint {
    var path: String {
        return rawValue
    }
}

extension API {
    var genericQueryItems: [URLQueryItem] {
        return []
    }
    
    func appendGenericPathComponents(to url: URL) -> URL {
        return url
    }
    
    func generateURLString(from endpoint: APIEndpoint, ids:[Token:String]?, queryItems: [URLQueryItem]?) -> String? {
        // convert baseURI string to NSURL to avoid cropping of protocol information:
        var baseURL = URL(string: baseURI)
        // appended path components will be URL encoded automatically:
        baseURL = appendGenericPathComponents(to: baseURL!.appendingPathComponent(endpoint.path))
        
        if let endTokens = endpoint.endTokens {
            baseURL = baseURL?.appendingPathComponent(endTokens)
        }
        // re-decode URL components so token placeholders can be replaced later:
        var populatedEndPoint: String = baseURL!.absoluteString.removingPercentEncoding!
        
        if let replacements = ids {
            for (token, value) in replacements {
                populatedEndPoint = populatedEndPoint.replacingOccurrences(of: "{\(token)}", with: value)
            }
        }
        
        var queryItemsWithGenericQueryItems = genericQueryItems
        
        if let queryItems = queryItems {
            queryItemsWithGenericQueryItems.append(contentsOf: queryItems)
        }
        
        if var urlComponents = URLComponents(string: populatedEndPoint) {
            urlComponents.queryItems = queryItemsWithGenericQueryItems
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
