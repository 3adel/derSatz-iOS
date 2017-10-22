//
//  GoogleAPI.swift
//  Texture
//
//  Created by Halil Gursoy on 02.10.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

public struct GoogleAPI: API {
    public typealias Endpoint = GoogleEndpoint
    public let baseURI: String = "https://translation.googleapis.com/language"
    public let apiKey: String = "AIzaSyAEy6HendzSLpnV682gKRPb0gpz_PxlcHE"
    
    public var genericQueryItems: [URLQueryItem] {
        return [ URLQueryItem(name: "key", value: apiKey) ]
    }
    
    public func appError(from apiError: APIError, for endpoint: GoogleEndpoint) -> APIError {
        switch (endpoint) {
        case .translate:
            return apiError
        }
        return .genericNetworkError
    }
    
    public func appendGenericPathComponents(to url: URL) -> URL {
        return url.appendingPathComponent("v2")
    }
}


public enum GoogleEndpoint: String, APIEndpoint {
    // MARKK - Locales
    case translate
    
    public var endTokens: String? {
        switch self {
        case .translate:
            return ""
        }
    }
}
