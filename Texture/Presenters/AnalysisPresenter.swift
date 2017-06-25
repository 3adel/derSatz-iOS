//
//  AnalysisPresenter.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP

//https://stackoverflow.com/questions/20694942/using-a-calayer-to-highlight-text-in-a-uitextview-which-spans-multiple-lines

struct AnalysisViewModel {
    let text: String
    let wordInfos: [WordInfo]
}

struct WordInfo {
    let word: String
    let lemma: String
    let type: String
    let range: NSRange
}

class AnalysisPresenter: Presenter, AnalysisPresenterProtocol {
    var wordInfos: [WordInfo] = []
    
    var inputText: String? {
        didSet {
            guard let text = inputText else { return }
            
            let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .nameTypeOrLexicalClass], options: 0)
            
            tagger.string = text
            
            let range = NSRange(location: 0, length: text.utf16.count)
            let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
            
            let words = text.words()
            
            var lemmas: [String] = []
            var types: [String] = []
            var ranges: [NSRange] = []
            
            tagger.enumerateTags(in: range,
                                 unit: .word,
                                 scheme: .lemma,
                                 options: options) { tag, tokenRange, stop in
//                                    guard let tag = tag else { return }
                                    lemmas.append(tag?.rawValue ?? "")
                                    ranges.append(tokenRange)
                                    let text = (text as NSString).substring(with: tokenRange)
            }
            
            tagger.enumerateTags(in: range,
                                 unit: .word,
                                 scheme: .nameTypeOrLexicalClass,
                                 options: options) { tag, tokenRange, stop in
//                                    guard let tag = tag else { return }
                                    types.append(tag?.rawValue ?? "")
                                    let text = (text as NSString).substring(with: tokenRange)
            }
            
//            print("Number of words: \(words.count) - Number of lemmas: \(lemmas.count) - Number of types: \(types.count)")
            
            words.enumerated().forEach {
                let wordInfo = WordInfo(word: $0.element,
                                        lemma: lemmas[$0.offset],
                                        type: types[$0.offset],
                                        range: ranges[$0.offset])
                
                wordInfos.append(wordInfo)
                
//                print("\($0.element) - Lemma: \(lemmas[$0.offset]), Type: \(types[$0.offset])")
            }
            
        }
    }
    
    weak var analysisView: AnalysisViewProtocol? {
        return view as? AnalysisViewProtocol
    }
    
    override func getInitialData() {
        guard let text = inputText else { return }
        let viewModel = AnalysisViewModel(text: text,
                                          wordInfos: wordInfos)
        
        analysisView?.render(with: viewModel)
    }
}

extension String {
    func words() -> [String] {
        
        let range = self.startIndex..<self.endIndex
        var words = [String]()
        
        self.enumerateSubstrings(in: range, options: .byWords) { (substring,  _, _, _) in
            guard let substring = substring else { return }
            words.append(substring)
        }
        
        return words
    }
}
