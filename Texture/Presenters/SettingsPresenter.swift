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
        case help
        case accountType
        
        var title: NSAttributedString {
            switch self {
            case .sendFeedback:
                return NSAttributedString(string: "Send Feedback")
            case .share:
                return NSAttributedString(string: "Share")
            case .reportBug:
                return NSAttributedString(string: "Report Bug")
            case .rate:
                return NSAttributedString(string: "Rate")
            case .translationLanguage:
                return NSAttributedString(string: "Translation Language")
            case .help:
                return NSAttributedString(string: "Help")
            case .accountType:
                let isPremium = IAPService.shared.purchasedProducts.contains(DerSatzIAProduct.premium)
                let accountType = isPremium  ? "Premium" : "Basic"
                let titleColor = isPremium ? UIColor(red: 238/255, green: 174/255, blue: 85/255, alpha: 1.0) : UIColor.black
                
                return NSAttributedString(string: accountType, attributes: [
                    NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: .semibold),
                    NSAttributedStringKey.foregroundColor: titleColor])
            }
        }
        
        var imageName: String {
            return "settings_"+rawValue
        }
    }
    
    struct TableCell {
        let cellType: CellType
        
        init(cellType: CellType) {
            self.cellType = cellType
        }
    }
    
    struct TableSection {
        let title: String
        let cells: [TableCell]
    }
    
    let accountTypeCells: [TableCell] = [
        TableCell(cellType: .accountType)
    ]
    
    let languageCells: [TableCell] = [
        TableCell(cellType: .translationLanguage)
    ]
    
    let optionCells: [TableCell] =  [
        TableCell(cellType: .help),
        TableCell(cellType: .reportBug),
        TableCell(cellType: .sendFeedback),
        TableCell(cellType: .share),
        TableCell(cellType: .rate)
    ]
    
    let accountTypeSection: TableSection
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
        accountTypeSection = TableSection(title: "Account Type", cells: accountTypeCells)
        
        languageSection = TableSection(title: "", cells: languageCells)
        
        optionSection = TableSection(title: "", cells: optionCells)
        
        sections = [accountTypeSection, languageSection, optionSection]
        
        super.init()
        self.router = router
    }
    
    func getOptions() {
        viewModel = makeViewModel(accountTypeSection: accountTypeSection, languageSection: languageSection, optionSection: optionSection)
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
        case .help:
            router?.routeToHelpSection()
        default: break
        }
    }
    
    func makeViewModel(accountTypeSection: TableSection, languageSection: TableSection, optionSection: TableSection) -> SettingsViewModel {
        let accountTypeSectionViewModel = makeSettingsOptionSectionViewModel(from: accountTypeSection)
        let languageSectionViewModel = makeSettingsLanguageSectionViewModel(from: languageSection)
        let optionSectionViewModel = makeSettingsOptionSectionViewModel(from: optionSection)
        
        let sectionViewModels = [accountTypeSectionViewModel, languageSectionViewModel, optionSectionViewModel]
        
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
        
        let conjugationViewModel = SettingsLanguageViewModel(title: section.cells[0].cellType.title.string,
                                                             languageName: conjugationLanguage,
                                                             languageImageName: conjugationLanguageImage)
        
        let translationViewModel = SettingsLanguageViewModel(title: section.cells[1].cellType.title.string,
                                                             languageName: translationLanguage,
                                                             languageImageName: translationLanguageImage)
        
        let cells = [conjugationViewModel, translationViewModel]
        
        return TableSectionViewModel(title: section.title, cells: cells)
    }
    
    func makeSettingsOptionViewModel(from cellData: TableCell) -> SettingsOptionViewModel {
        let title = cellData.cellType.title
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
        emailComposer?.sendEmail(withSubject: subject, recipient: "feedback@dersatz.me", version: versionNumber, build: buildNumber)
    }
    
    func rateUs(){
        UIApplication.shared.openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1299564210")! as URL)
    }
    
    func openTranslationLanguageSelection() {
        guard let appDependencyManager = appDependencyManager else { return }
        let selectedLanguage = appDependencyManager.languageConfig.selectedTranslationLanguage
        let languages = appDependencyManager.languageConfig.availableTranslationLanguages
        
        router?.routeToLanguageSelection(languages: languages, selectedLanguage: selectedLanguage, languageType: .interfaceLanguage)
    }
}
