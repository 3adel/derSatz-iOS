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
    let sentenceInfos: [SentenceViewModel]
}

struct WordViewModel {
    let word: String
    let lemma: String
    let type: String
    let range: NSRange
}

struct SentenceViewModel {
    let sentence: String
    let translation: String
    let wordInfos: [WordViewModel]
}

class AnalysisPresenter: Presenter, AnalysisPresenterProtocol {
    var sentenceInfos: [SentenceViewModel] = []
    
    fileprivate var inputText: String?
    
    weak var analysisView: AnalysisViewProtocol? {
        return view as? AnalysisViewProtocol
    }
    
    lazy var tagger: NSLinguisticTagger = {
       return NSLinguisticTagger(tagSchemes: [.lemma, .nameTypeOrLexicalClass], options: 0)
    }()
    
    let dataStore = DataStore()
    
    var dataIsReady = false
    var viewDidAskForInitialData = false
    
    override func getInitialData() {
        guard dataIsReady else {
            viewDidAskForInitialData = true
            return
        }
        
       updateView()
    }
    
    private func updateView() {
        guard let text = inputText else { return }
        let viewModel = AnalysisViewModel(text: text,
                                          sentenceInfos: sentenceInfos)
        
        analysisView?.render(with: viewModel)
    }
    
    private func parseSentences(in text: String) -> [String] {
        var sentences: [String] = []
        
        tagger.enumerateTags(in: text.fullRange,
                             unit: .sentence,
                             scheme: .nameTypeOrLexicalClass, options: .default) { tag, tokenRange, stop in
                                let sentence = (text as NSString).substring(with: tokenRange)
                                sentences.append(sentence)
        }
        return sentences
    }
    
    private func makeSentenceInfo(from sentence: String, translation: String) -> SentenceViewModel {
        let words = sentence.words()
        
        var lemmas: [String] = []
        var types: [String] = []
        var ranges: [NSRange] = []
        var wordInfos: [WordViewModel] = []
        
        tagger.string = sentence
        
        tagger.enumerateTags(in: sentence.fullRange,
                             unit: .word,
                             scheme: .lemma,
                             options: .default) { tag, tokenRange, stop in
                                lemmas.append(tag?.rawValue ?? "")
                                ranges.append(tokenRange)
//                                let text = (sentence as NSString).substring(with: tokenRange)
        }
        
        tagger.enumerateTags(in: sentence.fullRange,
                             unit: .word,
                             scheme: .nameTypeOrLexicalClass,
                             options: .default) { tag, tokenRange, stop in
                                types.append(tag?.rawValue ?? "")
//                                let text = (sentence as NSString).substring(with: tokenRange)
        }
        
        words.enumerated().forEach {
            let wordInfo = WordViewModel(word: $0.element,
                                    lemma: lemmas[$0.offset],
                                    type: types[$0.offset],
                                    range: ranges[$0.offset])
            
            wordInfos.append(wordInfo)
        }
        
        
        
        return SentenceViewModel(sentence: sentence,
                                 translation: translation,
                                 wordInfos: wordInfos)
    }
    
    func update(inputText: String) {
        self.inputText = inputText
        
        tagger.string = inputText
        
        let range = NSRange(location: 0, length: inputText.utf16.count)
        
        var sentences: [String] = []
        
        tagger.enumerateTags(in: range,
                             unit: .sentence,
                             scheme: .nameTypeOrLexicalClass, options: .default) { tag, tokenRange, stop in
                                let sentence = (inputText as NSString).substring(with: tokenRange)
                                sentences.append(sentence)
        }
        
        var translations = [String](repeatElement("", count: sentences.count))
        var numberOfTranslations = 0
        
        sentences.enumerated().forEach { index, sentence in
            self.dataStore.getTranslation(of: sentence, for: .english) { [weak self] result in
                numberOfTranslations += 1
                
                switch result {
                case .success(let translatedText):
                    translations[index] = translatedText
                default:
                    break
                }
                if numberOfTranslations == sentences.count {
                    self?.didGet(allTranslations: translations, forSentences: sentences)
                }
            }
        }
    }
    
    private func didGet(allTranslations translations: [String], forSentences sentences: [String]) {
        sentenceInfos = zip(sentences, translations).map(makeSentenceInfo)
        
        dataIsReady = true
        if viewDidAskForInitialData {
            updateView()
        }
    }
}

extension String {
    var fullRange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }
    
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

extension NSLinguisticTagger.Options {
    static var `default`: NSLinguisticTagger.Options {
        return [.omitPunctuation, .omitWhitespace]
    }
}
