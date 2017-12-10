//
//  ButtonStyleModel.swift
//  Texture
//
//  Created by Halil Gursoy on 10.12.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit

struct ButtonStyleModel {
    public var backgroundColor: UIColor?
    public var textColor: UIColor?
    public var font: UIFont?
    public var imageName: String?
    public var clipsToBounds: Bool = true
    public var cornerRadius: CGFloat
    public var borderWidth: CGFloat
    public var borderColor: UIColor?
    public var barButtonType: UIBarButtonSystemItem?
    
    public init(imageName: String?, backgroundColor: UIColor? = nil, textColor: UIColor? = nil, font: UIFont? = nil, cornerRadius: CGFloat = 0, borderWidth: CGFloat = 0, borderColor: UIColor? = nil, barButtonType: UIBarButtonSystemItem? = nil) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.font = font
        self.imageName = imageName
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.barButtonType = barButtonType
    }
}
