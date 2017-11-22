//
//  SettingsPresenter.swift
//  Conjugate
//
//  Created by Halil Gursoy on 06/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import RVMP

class SettingsPresenter: Presenter, SettingsPresenterType {
    enum CellType: String {
        case sendFeedback
        case share
        case reportBug
        case rate
        case translationLanguage
        
        var title: String {
            switch self {
            case .sendFeedback:
                return "Send Feedback"
            case .share:
                return "Share"
            case .reportBug:
                return "Report Bug"
            case .rate:
                return "Rate"
            case .translationLanguage:
                return "Translation Language"
            }
        }
        
        var imageName: String {
            return "settings_"+rawValue
        }
    }
    
    struct TableCell {
        let cellType: CellType
        let cellTitle: String
        
        init(cellType: CellType) {
            self.cellType = cellType
            self.cellTitle = cellType.title
        }
    }
    
    struct TableSection {
        let title: String
        let cells: [TableCell]
    }
    
    let languageCells: [TableCell] = [
        TableCell(cellType: .translationLanguage)
    ]
    
    let optionCells: [TableCell] =  [
        TableCell(cellType: .reportBug),
        TableCell(cellType: .sendFeedback),
        TableCell(cellType: .share),
        TableCell(cellType: .rate)
    ]
    
    let languageSection: TableSection
    let optionSection: TableSection
    
    let sections: [TableSection]
    
    var viewModel = SettingsViewModel.empty
    var emailComposer: EmailComposer?
    
    var appDependencyManager: AppDependencyManager?
    
    var settingsView: SettingsView? {
        return view as? SettingsView
    }
    
    required init(router: Router?) {
        languageSection = TableSection(title: "",
                                       cells: languageCells)
        
        optionSection = TableSection(title: "",
                                     cells: optionCells)
        
        sections = [languageSection, optionSection]
        
        super.init()
        self.router = router
    }
    
    func getOptions() {
        viewModel = makeViewModel(languageSection: languageSection, optionSection: optionSection)
        settingsView?.render(with: viewModel)
    }
    
    func optionSelected(at section: Int, index: Int, sourceView: ViewComponent, sourceRect: CGRect) {
        let option = sections[section].cells[index]
        
        switch option.cellType {
        case .reportBug:
            sendSupportEmail(subject: "der Satz iOS bug")
        case .sendFeedback:
            sendSupportEmail(subject: "der Satz iOS feedback")
        case .share:
            let shareController = ShareController(router: router!)
            shareController.shareApp(sourceView: sourceView, sourceRect: sourceRect)
        case .rate:
            rateUs()
        case .translationLanguage:
            openTranslationLanguageSelection()
        }
    }
    
    func makeViewModel(languageSection: TableSection, optionSection: TableSection) -> SettingsViewModel {
        let languageSectionViewModel = makeSettingsLanguageSectionViewModel(from: languageSection)
        let optionSectionViewModel = makeSettingsOptionSectionViewModel(from: optionSection)
        
        let sectionViewModels = [languageSectionViewModel, optionSectionViewModel]
        
        let footerURL = ""
        let footerTitle = ""
        
        return SettingsViewModel(sections: sectionViewModels, footerTitle: footerTitle, footerURL: footerURL)
    }
    
    func makeSettingsOptionSectionViewModel(from section: TableSection) -> TableSectionViewModel {
        let title = section.title
        let cellViewModels = section.cells.map(makeSettingsOptionViewModel)
        
        return TableSectionViewModel(title: title, cells: cellViewModels)
    }
    
    func makeSettingsLanguageSectionViewModel(from section: TableSection) -> TableSectionViewModel {
        guard let languageConfig = appDependencyManager?.languageConfig else { return .empty() }
        
        let conjugationLanguage = languageConfig.selectedConjugationLanguage.displayLanguageCode.uppercased()
        let conjugationLanguageImage = languageConfig.selectedConjugationLanguage.flagImageName
        
        let translationLanguage = languageConfig.selectedTranslationLanguage.displayLanguageCode.uppercased()
        let translationLanguageImage = languageConfig.selectedTranslationLanguage.flagImageName
        
        let conjugationViewModel = SettingsLanguageViewModel(title: section.cells[0].cellTitle,
                                                             languageName: conjugationLanguage,
                                                             languageImageName: conjugationLanguageImage)
        
        let translationViewModel = SettingsLanguageViewModel(title: section.cells[1].cellTitle,
                                                             languageName: translationLanguage,
                                                             languageImageName: translationLanguageImage)
        
        let cells = [conjugationViewModel, translationViewModel]
        
        return TableSectionViewModel(title: section.title, cells: cells)
    }
    
    func makeSettingsOptionViewModel(from cellData: TableCell) -> SettingsOptionViewModel {
        let title = cellData.cellTitle
        let imageName = cellData.cellType.imageName
        
        return SettingsOptionViewModel(title: title, imageName: imageName)
    }
    
    func sendSupportEmail(subject: String) {
        guard let view = view,
            let infoDict = Bundle.main.infoDictionary,
            let versionNumber = infoDict["CFBundleShortVersionString"] as? String,
            let buildNumber = infoDict["CFBundleVersion"] as? String
            else {
                return
        }
        
        emailComposer = EmailComposer(view: view)
        emailComposer?.sendEmail(withSubject: subject, recipient: "feedback@konj.me", version: versionNumber, build: buildNumber)
    }
    
    func rateUs(){
        UIApplication.shared.openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1163600729")! as URL)
    }
    
    func openTranslationLanguageSelection() {
        guard let appDependencyManager = appDependencyManager else { return }
        let selectedLanguage = appDependencyManager.languageConfig.selectedTranslationLanguage
        let languages = appDependencyManager.languageConfig.availableTranslationLanguages
        
        router?.routeToLanguageSelection(languages: languages, selectedLanguage: selectedLanguage, languageType: .interfaceLanguage)
    }
}
