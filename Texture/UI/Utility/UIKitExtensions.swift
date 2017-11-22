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
    
    public func setupTabBar(shouldShow: Bool) {
        let bottomPoint = tabBarController!.view.frame.height
        let yPoint = shouldShow ? bottomPoint - (tabBarController?.tabBar.frame.height)! : bottomPoint
        
        UIView.animate(withDuration: 0.3) {
            var frame = self.tabBarController!.tabBar.frame
            frame.origin.y = yPoint
            
            self.tabBarController?.tabBar.frame = frame
            self.tabBarController?.tabBar.isHidden = !shouldShow
        }
    }
}

extension UIView {
    static func from(nibWithName name: String, bundle: Bundle = .main) -> UIView? {
        return bundle.loadNibNamed(name, owner: nil, options: nil)?.first as? UIView
    }
}

extension UIImage {
    
    func tint(with color: UIColor) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context.setBlendMode(.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context.fill(rect)
        
        // create UIImage
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UIView {
    func setHeightConstraint(to height: CGFloat) {
        if let constraint = constraints.filter({ $0.firstAttribute == .width }).first {
            constraint.constant = height
        } else {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

// MARK: - device

public func isPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
}

public func isPhone() -> Bool {
    return (!isPad()) && UIApplication.shared.canOpenURL(URL(string: "tel:123")!)
}

extension NSMutableAttributedString {
    
    @discardableResult
    public func set(_ text :String, asLink link:String) -> Bool {
        let foundRange = self.mutableString.range(of: text)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: link, range: foundRange)
            return true
        }
        return false
    }
}
