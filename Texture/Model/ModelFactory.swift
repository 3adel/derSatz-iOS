//
//  ModelFactory.swift
//  Texture
//
//  Created by Halil Gursoy on 23.08.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

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
