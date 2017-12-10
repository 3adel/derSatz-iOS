//
//  LexicalClass.swift
//  Texture
//
//  Created by Halil Gursoy on 26.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit

enum LexicalClass: String {
    case noun = "Noun"
    case verb = "Verb"
    case adjective = "Adjective"
    case adverb = "Adverb"
    case pronoun = "Pronoun"
    case conjunction = "Conjunction"
    case preposition = "Preposition"
    case other
    
    var color: UIColor {
        switch self {
        case .noun:
            return UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        case.verb:
            return UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        case .pronoun:
            return UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        case .adverb:
            return UIColor(red: 76/255, green: 205/255, blue: 100/255, alpha: 1)
        case .adjective:
            return UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        case .preposition:
            return UIColor(red: 192/255, green: 68/255, blue: 245/255, alpha: 1)
        case .conjunction:
            return UIColor(red: 0/255, green: 187/255, blue: 208/255, alpha: 1)
        default:
            return UIColor.black
        }
    }
}
