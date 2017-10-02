//
//  TextAnalyzerAPI.swift
//  Texture
//
//  Created by Halil Gursoy on 02.10.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

struct TextAnalyzerAPI: API {
    typealias Endpoint = TextAnalyzerEndpoint
    public let baseURI: String = "http://138.68.65.167"
    public let apiKey: String = ""
    
    func appError(from apiError: APIError, for endpoint: TextAnalyzerEndpoint) -> APIError {
        return .genericNetworkError
    }
}

enum TextAnalyzerEndpoint: String, APIEndpoint {
    case api
    
    var endTokens: String {
        return ""
    }
}
