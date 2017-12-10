//
//  AnalysisPresenter.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import RVMP

class AnalysisPresenter: Presenter {
    var sentenceInfos: [SentenceViewModel] = []
    
    fileprivate var inputText: String?
    
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
        guard dataIsReady else {
            viewDidAskForInitialData = true
            return
        }
        
       updateView()
    }
    
    override func viewDidAppear() {
        getInitialData()
    }
    
    private func updateView() {
        guard let text = inputText else { return }
        
        var headerViewModel: ArticleImageHeaderViewModel? = nil
        
        if let article = article {
            headerViewModel = makeHeaderViewModel(from: article)
            dataStore.isArticleSaved(article) { [weak self] result in
                guard let `self` = self else { return }
                
                var isSaved = false
                switch result {
                case .success(let saved):
                    isSaved = saved
                default:
                    break
                }
                let viewModel = AnalysisViewModel(text: text,
                                                  sentenceInfos: self.sentenceInfos,
                                                  headerViewModel: headerViewModel,
                                                  isSaved: isSaved)
                
                self.analysisView?.render(with: viewModel)
            }
        } else {
            let viewModel = AnalysisViewModel(text: text,
                                              sentenceInfos: sentenceInfos,
                                              headerViewModel: headerViewModel,
                                              isSaved: false)
            
            analysisView?.render(with: viewModel)
        }
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
    
    private func makeHeaderViewModel(from article: Article) -> ArticleImageHeaderViewModel? {
        return ArticleImageHeaderViewModel(title: article.title, imageURL: article.topImageURL)
    }
    
    func update(inputURL url: URL) {
        dataStore.getArticle(at: url) { [weak self] result in
            switch result {
            case .success(let article):
                self?.article = article
            case .failure(let error):
                self?.view?.show(errorMessage: "Something went wrong")
            }
        }
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
        
        sentences = sentences.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        
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
                                                                   backgroundColor: wordInfo.type.color)
                
                self?.analysisView?.showWordDetailPopup(with: wordDetailViewModel, forWordAt: index, inSentenceAt: sentenceIndex)
            default:
                break
            }
        }
    }
    
    func didTapOnSaveToggle(toggleSet: Bool) {
        guard let article = article else { return }
        if toggleSet {
            dataStore.save(article) { _ in }
        } else {
            dataStore.deleteSavedArticle(article) { _ in }
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
