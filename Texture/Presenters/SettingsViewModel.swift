//
//  SettingsViewModel.swift
//  Texture
//
//  Created by Halil Gursoy on 22.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

struct SettingsViewModel {
    let sections: [TableSectionViewModel]
    let footerTitle: String
    let footerURL: String
    
    static let empty: SettingsViewModel = SettingsViewModel(sections: [], footerTitle: "", footerURL: "")
}

protocol CellViewModel {}

struct TableSectionViewModel {
    let title: String
    let cells: [CellViewModel]
    
    static func empty() -> TableSectionViewModel {
        return TableSectionViewModel(title: "", cells: [])
    }
}

struct SettingsOptionViewModel: CellViewModel {
    let title: NSAttributedString
    let imageName: String
}

struct SettingsLanguageViewModel: CellViewModel {
    let title: String
    let languageName: String
    let languageImageName: String
}

struct LanguageViewModel {
    let title: String
    let imageName: String
    let isSelected: Bool
}
