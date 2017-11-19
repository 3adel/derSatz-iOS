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
    func setUpAppWideTheme() {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballPulse
        NVActivityIndicatorView.DEFAULT_COLOR = .darkGray
        NVActivityIndicatorView.DEFAULT_TEXT_COLOR = .darkGray
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = .clear
        NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD = 20
    }
}
