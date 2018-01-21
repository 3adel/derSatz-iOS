//
//  UserDefaultsExtensions.swift
//  Texture
//
//  Created by Halil Gursoy on 21.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case didUseAnalysisBefore
        
        var keyValue: String { return rawValue }
    }
    
    var didUseAnalysisBefore: Bool {
        get { return bool(forKey: Key.didUseAnalysisBefore.keyValue) }
        set { set(newValue, forKey: Key.didUseAnalysisBefore.keyValue) }
    }
}
