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
    
    fileprivate var articleTitleTranslation: String?
    
    fileprivate var analysisView: AnalysisViewProtocol? {
        return view as? AnalysisViewProtocol
    }
    
    private var language: Language {
        if let dominantLanguage = tagger.dominantLanguage {
            return Language(languageCode: dominantLanguage) ?? .german
        } else {
            return .german
        }
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
            headerViewModel = article.source == .internet ? makeHeaderViewModel(from: article) : nil
            dataStore.isArticleSaved(article) { [weak self] result in
                guard let `self` = self else { return }
                
                var isSaved = false
                switch result {
                case .success(let saved):
                    isSaved = saved
                default:
                    break
                }
                
                
                var sourceViewModel: SourceViewModel? = nil
                if let url = article.url {
                    sourceViewModel = SourceViewModel(urlString: url.absoluteString)
                }
                
                let viewModel = AnalysisViewModel(text: text,
                                                  sentenceInfos: self.sentenceInfos,
                                                  headerViewModel: headerViewModel,
                                                  isSaved: isSaved,
                                                  source: sourceViewModel)
                
                self.analysisView?.render(with: viewModel)
            }
        } else {
            let viewModel = AnalysisViewModel(text: text,
                                              sentenceInfos: sentenceInfos,
                                              headerViewModel: headerViewModel,
                                              isSaved: false,
                                              source: nil)
            
            analysisView?.render(with: viewModel)
        }
    }
    
    private func makeSentenceInfo(from sentence: String, translation: String, fontWeight: UIFont.Weight) -> SentenceViewModel {
        
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
                                 wordInfos: wordInfos,
                                 fontWeight: fontWeight,
                                 language: language)
    }
    
    private func makeHeaderViewModel(from article: Article) -> ArticleImageHeaderViewModel? {
        return ArticleImageHeaderViewModel(title: article.title, imageURL: article.topImageURL)
    }
    
    func update(inputURL url: URL) {
        view?.showLoader()
        dataStore.getArticle(at: url) { [weak self] result in
            self?.view?.hideLoader()
            
            switch result {
            case .success(let article):
                self?.article = article
            case .failure(_):
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
        
        if let article = article {
            dataStore.getTranslation(of: article.title, for: .english) { [weak self] result in
                switch result {
                case .success(let translation):
                    self?.articleTitleTranslation = translation.translatedText
                    self?.getTranslations(for: sentences)
                default:
                    break
                }
            }
        } else {
            getTranslations(for: sentences)
        }
    }
    
    private func getTranslations(for sentences: [String]) {
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
        
        if let article = article,
            article.source == .internet,
            let articleTitleTranslation = articleTitleTranslation {
            let titleSentenceInfo = makeSentenceInfo(from: article.title, translation: articleTitleTranslation, fontWeight: .bold)
            sentenceInfos.append(titleSentenceInfo)
        }
        
        sentences.enumerated().forEach { tuple in
            let viewModel = makeSentenceInfo(from: tuple.element, translation: translations[tuple.offset], fontWeight: .regular)
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
        
        let viewModel = makeWordDetailPopupViewModel(with: wordInfo)
        analysisView?.showWordDetailPopup(with: viewModel, forWordAt: index, inSentenceAt: sentenceIndex)
        
        dataStore.getTranslation(of: wordInfo.word, for: .english) { [weak self] result in
            guard let `self` = self else { return }
            var translation: Translation?
            switch result {
            case .success(let fetchedTranslation):
                translation = fetchedTranslation
            default:
                break
            }
            let wordDetailViewModel = self.makeWordDetailPopupViewModel(with: wordInfo, translation: translation?.translatedText)
            self.analysisView?.updateWordDetailPopup(with: wordDetailViewModel, showLoader: false)
        }
    }
    
    func didTapOnSaveToggle(toggleSet: Bool) {
        let article = self.article ?? Article(freeText: inputText!)
        
        if toggleSet {
            switch FeatureConfig.shared.status(for: .savedArticles) {
            case .disabled(let errorMessage):
                view?.show(errorMessage: errorMessage)
                analysisView?.updateSaveToggle(false)
                return
            case .trial:
                guard FeatureConfig.shared.shouldShowPromotion(for: .savedArticles) else { return }
                router?.showPremiumPopup()
            default: break
            }
            
            dataStore.save(article) { _ in }
        } else {
            dataStore.deleteSavedArticle(article) { _ in }
        }
    }
    
    func didTapOnSource() {
        guard let url = article?.url else { return }
        router?.routeToWebView(url: url)
    }
    
    private func makeWordDetailPopupViewModel(with wordInfo: WordViewModel, translation: String? = nil) -> WordDetailPopupViewModel {
        let translationText = translation ?? ""
        return WordDetailPopupViewModel(word: wordInfo.word,
                                 translation: translationText,
                                 originalLanguageImageName: language.flagImageName,
                                 translatedLanguageImageName: "gb_flag",
                                 lemma: wordInfo.lemma,
                                 lexicalClass: wordInfo.type.rawValue,
                                 backgroundColor: wordInfo.type.color,
                                 language: language)
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
