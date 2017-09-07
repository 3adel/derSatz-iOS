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
            let languageCode = dict["detectedSourceLanguage"] as? String,
            let translatedLanguage = Language(languageCode: languageCode) else {
                return nil
        }
        self.init(translatedText: encodedTranslatedText.removingHTMLEntities, translationLanguage: translatedLanguage)
    }
}
