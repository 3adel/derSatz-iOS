//
//  SavedViewController.swift
//  Texture
//
//  Created by Halil Gursoy on 18.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import RVMP

class SavedViewController: UIViewController, View {
    var presenter: BasePresenter?
    
    private let themeService = ThemeService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = navigationController?.navigationBar {
            themeService.setUpLightUI(for: navigationBar)
        }
    }
}
