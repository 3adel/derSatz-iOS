//
//  SentenceViewModel.swift
//  Texture
//
//  Created by Halil Gursoy on 26.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

struct WordViewModel {
    let word: String
    let lemma: String
    let type: LexicalClass
    let range: NSRange
}

struct SentenceViewModel {
    let sentence: String
    let translation: String
    let wordInfos: [WordViewModel]
}
