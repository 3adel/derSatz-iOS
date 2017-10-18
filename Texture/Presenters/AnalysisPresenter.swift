//
//  AnalysisPresenter.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP

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
    
    var color: UIColor {
        switch self {
        case .noun:
            return UIColor(red: 13/255, green: 113/255, blue: 230/255, alpha: 1)
        case.verb:
            return UIColor(red: 208/255, green: 2/255, blue: 27/255, alpha: 1)
        case .pronoun:
            return UIColor(red: 208/255, green: 2/255, blue: 27/255, alpha: 1)
        case .adverb:
            return UIColor(red: 108/255, green: 201/255, blue: 7/255, alpha: 1)
        case .adjective:
            return UIColor(red: 144/255, green: 19/255, blue: 254/255, alpha: 1)
        default:
            return UIColor.black
        }
    }
}

class AnalysisPresenter: Presenter {
    var sentenceInfos: [SentenceViewModel] = []
    
    var inputText: String?
    
    var article: Article? {
        didSet {
            guard let text = article?.body else { return }
            update(inputText: text)
        }
    }
    
    fileprivate var analysisView: AnalysisViewProtocol? {
        return view as? AnalysisViewProtocol
    }
    
    lazy var tagger: NSLinguisticTagger = {
        let options: NSLinguisticTagger.Options = [NSLinguisticTagger.Options.joinNames]
       return NSLinguisticTagger(tagSchemes: [.lemma, .nameTypeOrLexicalClass], options: Int(options.rawValue))
    }()
    
    let dataStore = DataStore()
    
    var dataIsReady = false
    var viewDidAskForInitialData = false
    
    override func getInitialData() {
        if let urlString = inputText,
            let _ = URL(string: urlString) {
             viewDidAskForInitialData = true
            dataStore.getArticle(at: urlString) { [weak self] result in
                switch result {
                case .success(let article):
                    self?.article = article
                default:
                    break
                }
            }
        } else {
            guard dataIsReady else { viewDidAskForInitialData = true; return }
            updateView()
        }
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
        
        var words: [String] = []
        var lemmas: [String] = []
        var types: [LexicalClass] = []
        var ranges: [NSRange] = []
        
        tagger.string = sentence
        
        tagger.enumerateTags(in: sentence.fullRange,
                             unit: .word,
                             scheme: .lemma,
                             options: .default) { tag, tokenRange, stop in
                                let word = (sentence as NSString).substring(with: tokenRange)
                                words.append(word)
                                lemmas.append(tag?.rawValue ?? "")
                                ranges.append(tokenRange)
        }
        
        tagger.enumerateTags(in: sentence.fullRange,
                             unit: .word,
                             scheme: .nameTypeOrLexicalClass,
                             options: .default) { tag, tokenRange, stop in
                                types.append(LexicalClass(rawValue: tag?.rawValue ?? "") ?? .other)
        }
        
        let wordInfos: [WordViewModel] = words.enumerated().reduce([]) { wordInfoList, enumerated in
            let wordInfo = WordViewModel(word: enumerated.element,
                                    lemma: lemmas[enumerated.offset],
                                    type: types[enumerated.offset],
                                    range: ranges[enumerated.offset])
            
            var wordInfoList = wordInfoList
            wordInfoList.append(wordInfo)
            return wordInfoList
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
                                guard sentence != "\n" else { return }
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

extension AnalysisPresenter: AnalysisPresenterProtocol {
    func didTapOnWord(at index: Int, inSentenceAt sentenceIndex: Int) {
        let sentenceInfo = sentenceInfos[sentenceIndex]
        let wordInfo = sentenceInfo.wordInfos[index]
        
        guard wordInfo.type != .other else { return }
        
        dataStore.getTranslation(of: wordInfo.word, for: .english) { [weak self] result in
            switch result {
            case .success(let translation):
                let wordDetailViewModel = WordDetailPopupViewModel(word: wordInfo.word,
                                                                   translation: translation,
                                                                   originalLanguageImageName: "de_flag",
                                                                   translatedLanguageImageName: "gb_flag",
                                                                   lemma: wordInfo.lemma,
                                                                   lexicalClass: wordInfo.type.rawValue,
                                                                   backgroundColor: wordInfo.type.color.withAlphaComponent(0.99))
                
                self?.analysisView?.showWordDetailPopup(with: wordDetailViewModel, forWordAt: index, inSentenceAt: sentenceIndex)
            default:
                break
            }
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
            guard let substring = substring,
               Int(substring) == nil else { return }
            
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
