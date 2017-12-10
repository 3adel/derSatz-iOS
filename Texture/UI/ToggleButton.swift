//
//  ToggleButton.swift
//  Texture
//
//  Created by Halil Gursoy on 10.12.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit

class ToggleButton: UIButton {
    var titleForTrue: String? {
        didSet {
            if toggleSet { setTitle(titleForTrue, for: .normal) }
        }
    }
    var titleForFalse: String? {
        didSet {
            if !toggleSet { setTitle(titleForFalse, for: .normal) }
        }
    }
    
    var onToggle: ((Bool) -> Void)?
    
    var styleForTrue: ButtonStyleModel? {
        didSet {
            if let styleModel = styleForTrue, toggleSet { setupUI(with: styleModel) }
        }
    }
    var styleForFalse: ButtonStyleModel? {
        didSet {
            if let styleModel = styleForFalse, !toggleSet { setupUI(with: styleModel) }
        }
    }
    var styleAnimationDuration: TimeInterval = 0
    
    var toggleSet = false {
        didSet {
            var styleIfSet: ButtonStyleModel?
            
            if toggleSet {
                setTitle(titleForTrue, for: .normal)
                styleIfSet = styleForTrue
            } else {
                setTitle(titleForFalse, for: .normal)
                styleIfSet = styleForFalse
            }
            guard let style = styleIfSet else { return }
            
            UIView.animate(withDuration: styleAnimationDuration) {
                self.setupUI(with: style)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    @objc func didTap() {
        toggleSet = !toggleSet
        onToggle?(toggleSet)
    }
    
    private func setupUI(with styleModel: ButtonStyleModel) {
        if let backgroundColor = styleModel.backgroundColor {
            self.backgroundColor = backgroundColor
        }
        
        if let borderColor = styleModel.borderColor {
            self.layer.borderColor = borderColor.cgColor
        }
        
        if let textColor = styleModel.textColor {
            setTitleColor(textColor, for: .normal)
        }
        
        if let imageName = styleModel.imageName {
            setImage(UIImage(named: imageName), for: .normal)
        }
        
        self.layer.cornerRadius = styleModel.cornerRadius
        self.layer.borderWidth = styleModel.borderWidth
    }
    
    private func setup() {
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
}

