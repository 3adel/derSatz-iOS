//
//  ModelFactory.swift
//  Texture
//
//  Created by Halil Gursoy on 23.08.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import HTMLString

public typealias JSONDictionary = [String: Any]

public typealias JSONArray = [Any]
public typealias JSONNumber = Double
public typealias JSONString = String

/**
 
 Implement this protocol to allow a object to be initiated with a JSONDictionary instance
 
 */
public protocol JSONDictInitable {
    init?(with dict: JSONDictionary)
}

open class ModelFactory {
    open static func arrayOf<T:JSONDictInitable>(_ inArray:[JSONDictionary]?) -> [T] {
        
        guard let inArray = inArray else { return [] }
        
        return inArray.flatMap { T(with: $0) }
    }
    
    open static func dictionaryOf<T:JSONDictInitable>(_ inDict:[String : JSONDictionary]?) -> [String : T] {
        
        guard let inDict = inDict else { return [:] }
        
        return inDict.reduce([String: T]()) { (dict, element) in
            var dictionary = dict
            dictionary[element.0] = T(with: element.1)
            return dictionary
        }
    }
}


extension Translation: JSONDictInitable {
    init?(with dict: JSONDictionary) {
        guard let encodedTranslatedText = dict["translatedText"] as? String,
            let languageCode = dict["detectedSourceLanguage"] as? String else { return nil }
        
        let translatedLanguage = Language(languageCode: languageCode) ?? .german
        self.init(translatedText: encodedTranslatedText.removingHTMLEntities, translationLanguage: translatedLanguage)
    }
}

extension Article: JSONDictInitable {
    init?(with dict: JSONDictionary) {
        guard let title = dict["articleTitle"] as? String,
            let summary = dict["articleNLPSummary"] as? String,
            let body = dict["articleText"] as? String else { return nil }
        
        var topImageURL: URL? = nil
        if let topImageURLString = dict["articleTopImage"] as? String {
            topImageURL = URL(string: topImageURLString)
        }
        self.init(title: title, url: nil, topImageURL: topImageURL, summary: summary.removingHTMLEntities, body: body.removingHTMLEntities)
    }
}
