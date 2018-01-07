//
//  UIView+EasyLayout.swift
//  Texture
//
//  Created by Halil Gursoy on 07.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import UIKit

extension UIView {
    var widthConstraintValue: CGFloat? {
        get {
            return widthConstraint?.constant
        }
        set(value) {
            //If setting
            guard let value = value else {
                remove(widthConstraint)
                return
            }
            setDimensionalConstraint(value: value, attribute: .width)
        }
    }
    
    var heightConstraintValue: CGFloat? {
        get {
            return heightConstraint?.constant
        }
        set(value) {
            guard let value = value else {
                remove(heightConstraint)
                return
            }
            setDimensionalConstraint(value: value, attribute: .height)
        }
    }
    
    var widthConstraint: NSLayoutConstraint? {
        return getDimensionalConstraint(for: .width)
    }
    
    var heightConstraint: NSLayoutConstraint? {
        return getDimensionalConstraint(for: .height)
    }
    
    static func disable(_ constraint: NSLayoutConstraint?) {
        guard let constraint = constraint else { return }
        NSLayoutConstraint.deactivate([constraint])
    }
    
    static func activate(_ constraint: NSLayoutConstraint?) {
        guard let constraint = constraint else { return }
        NSLayoutConstraint.activate([constraint])
    }
    
    func remove(_ constraint: NSLayoutConstraint?) {
        if let constraint = constraint {
            removeConstraint(constraint)
        }
    }
    
    private func setDimensionalConstraint(value: CGFloat, attribute: NSLayoutAttribute) {
        let dimensionalConstraint = attribute == .width ? widthConstraint : heightConstraint
        
        if let constraint = dimensionalConstraint {
            constraint.constant = value
        } else {
            let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
            self.addConstraint(constraint)
        }
    }
    
    private func getDimensionalConstraint(for attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        let dimensionalConstraints = constraints.filter({ constraint in
            return constraint.firstItem === self && constraint.firstAttribute == attribute && constraint.secondItem == nil
        })
        
        return dimensionalConstraints.last
    }
    
}

