//
//  ThemeService.swift
//  Texture
//
//  Created by Halil Gursoy on 18.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class ThemeService {
    let tintColor = UIColor(red: 92/255, green: 146/255, blue: 253/255, alpha: 1.0)
    let textColor = UIColor.white
    let ctaButtonColor = UIColor(red: 76/255, green: 205/255, blue: 100/255, alpha: 1.0)
    
    func setUpAppWideTheme() {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballPulse
        NVActivityIndicatorView.DEFAULT_COLOR = .darkGray
        NVActivityIndicatorView.DEFAULT_TEXT_COLOR = .darkGray
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = .clear
        NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD = 20
    }
    
    func setUpDefaultUI(for navigationBar: UINavigationBar) {
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = textColor
        navigationBar.barTintColor = tintColor
        navigationBar.titleTextAttributes = [.foregroundColor: textColor]
        #if TARGET_IS_APP
        UIApplication.shared.statusBarStyle = .lightContent
        #endif
    }
    
    func setUpLightUI(for navigationBar: UINavigationBar) {
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = nil
        navigationBar.tintColor = .black
        navigationBar.barTintColor = .white
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        #if TARGET_IS_APP
        UIApplication.shared.statusBarStyle = .default
        #endif
    }
    
    func setUpDefaultUI(for ctaButton: UIButton) {
        ctaButton.backgroundColor = ctaButtonColor
        ctaButton.setTitleColor(textColor, for: .normal)
    }
}
