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

public func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                                  execute: closure)
}

struct AnalysisViewModel {
    let text: String
    let sentenceInfos: [SentenceViewModel]
}

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

enum LexicalClass: String {
    case noun = "Noun"
    case verb = "Verb"
    case adjective = "Adjective"
    case adverb = "Adverb"
    case pronoun = "Pronoun"
    case other
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
        var types: [LexicalClass] = []
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
                                types.append(LexicalClass(rawValue: tag?.rawValue ?? "") ?? .other)
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
        
        view?.showLoader()
        dataStore.getTranslation(of: sentences, to: .english) { [weak self] result in
            self?.view?.hideLoader()
            
            switch result {
            case .success(let translations):
                let translatedSentences = translations.map { $0.translatedText }
                self?.didGet(allTranslations: translatedSentences, forSentences: sentences)
            default :
                break
            }
        }
    }
    
    private func didGet(allTranslations translations: [String], forSentences sentences: [String]) {
        sentenceInfos.removeAll()
        
        sentences.enumerated().forEach { tuple in
            let viewModel = makeSentenceInfo(from: tuple.element, translation: translations[tuple.offset])
            sentenceInfos.append(viewModel)
        }
        
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
