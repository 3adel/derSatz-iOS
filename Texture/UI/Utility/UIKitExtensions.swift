//
//  UIKit Extensions.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: .main)
    }
}

public extension UIViewController {
    
    public func hideBackButtonText() {
        guard let _ = navigationController?.navigationBar else { return }
        
        let backButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationItem.backBarButtonItem = backButtonItem
    }
}

