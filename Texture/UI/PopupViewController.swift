//
//  PopupViewController.swift
//  Texture
//
//  Created by Halil Gursoy on 28.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {
    var backgroundView = UIVisualEffectView(frame: .zero)
    var popupContainerView = UIView(frame: .zero)
    
    var completion: (() -> Void)?
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(backgroundView)
        backgroundView.snapToSuperview()
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))
        
        view.addSubview(popupContainerView)
        popupContainerView.setWidth(equalToConstant: 320)
        popupContainerView.setHeight(equalToConstant: 500)
        popupContainerView.placeOnBottom(ofView: view)
        popupContainerView.centerHorizontallyInSuperview()
        
        popupContainerView.layer.cornerRadius = 12
        popupContainerView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .dark)
        backgroundView.effect = blurEffect
        
        view.backgroundColor = .clear
        
        backgroundView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        popupContainerView.centerInSuperview()
        view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func embed(viewController: UIViewController) {
        addChildViewController(viewController)
        
        popupContainerView.addSubview(viewController.view)
        viewController.view.snapToSuperview()
    }
    
    @objc
    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        popupContainerView.placeOnBottom(ofView: view)
        view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.backgroundView.alpha = 0
        }) { _ in
            super.dismiss(animated: flag) {
                self.completion?()
                completion?()
            }
        }
    }
}
