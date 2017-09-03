//
//  Language.swift
//  Texture
//
//  Created by Halil Gursoy on 23.08.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

public enum Language: String {
    case
    german,
    english,
    spanish,
    french,
    mandarin,
    hindi,
    portuguese,
    arabic,
    bengali,
    russian,
    punjabi,
    japanese,
    telugu,
    malay,
    korean,
    tamil,
    marathi,
    turkish,
    vietnamese,
    urdu,
    italian,
    persian,
    swahili,
    dutch,
    swedish
    
    static var localeIdentifiers: [Language: String] {
        get {
            return [
                .german: "de_DE",
                .english: "en_GB",
                .spanish: "es_ES",
                .french: "fr_FR",
                .mandarin: "zh_Hans_CN",
                .hindi: "hi_IN",
                .portuguese: "pt_PT",
                .arabic: "ar_SA",
                .bengali: "bn_BD",
                .russian: "ru_RU",
                .punjabi: "pa_Arab_PK",
                .japanese: "ja_JP",
                .telugu: "te_IN",
                .malay: "ms_MY",
                .korean: "ko_KR",
                .tamil: "ta_LK",
                .marathi: "mr_IN",
                .turkish: "tr_TR",
                .vietnamese: "vi_VN",
                .urdu: "ur_PK",
                .italian: "it_IT",
                .persian: "fa_IR",
                .swahili: "sw_TZ",
                .dutch: "nl_NL",
                .swedish: "sv_SE"
            ]
        }
    }
    
    init?(localeIdentifier: String) {
        guard let locale = Language.localeIdentifiers.filter ({ $0.value == localeIdentifier }).first
            else { return nil }
        
        self = locale.key
    }
    
    init?(languageCode: String) {
        guard let locale = Language.localeIdentifiers.filter({ keyValue in
            let didFindLanguage = (keyValue.value.components(separatedBy: "_").first ?? "") == languageCode
            return didFindLanguage
        }).first
            else { return nil }
        
        self = locale.key
    }
    
    static func makeLanguage(withLocaleIdentifier localeIdentifier: String) -> Language? {
        return Language(localeIdentifier: localeIdentifier)
    }
    
    var name: String {
        get {
            return rawValue.capitalized
        }
    }
    
    var localeIdentifier: String {
        get {
            return Language.localeIdentifiers[self]!
        }
    }
    
    var languageCode: String {
        get {
            switch self {
            case .mandarin:
                return "cmn"
            case .punjabi:
                return "pa"
            default:
                return self.locale.languageCode!
            }
        }
    }
    
    //Special case for Mandarin
    var displayLanguageCode: String {
        get {
            switch self {
            case .mandarin:
                return "zh"
            default:
                return self.languageCode
            }
        }
    }
    
    //Special case for Mandarin
    var minWordCharacterCount: Int {
        get {
            switch self {
            case .mandarin:
                return 1
            default:
                return 2
            }
        }
    }
    
    var isoCode: String {
        get {
            switch(self) {
            case .english:
                return "eng"
            case .german:
                return "deu"
            case .spanish:
                return "spa"
            case .french:
                return "fra"
            case .italian:
                return "ita"
            case .portuguese:
                return "por"
            case .dutch:
                return "nld"
            case .swedish:
                return "swe"
            default:
                return ""
            }
        }
    }
    
    var countryCode: String {
        get {
            return self.locale.regionCode!
        }
    }
    
    var locale: Locale {
        get {
            return Locale(identifier: localeIdentifier)
        }
    }
}
