//
//  FoundationExtensions.swift
//  Texture
//
//  Created by Halil Gursoy on 04.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit

extension UITextRange {
    static func from(range: NSRange, in textView: UITextView) -> UITextRange? {
        let beginning = textView.beginningOfDocument
        guard let start = textView.position(from: beginning, offset: range.location),
            let end = textView.position(from: start, offset: range.length) else { return nil }
        
        return textView.textRange(from: start, to: end)
    }
    func toRange(in textView: UITextView) -> NSRange {
        let location: Int = textView.offset(from: textView.beginningOfDocument, to: self.start)
        let length: Int = textView.offset(from: self.start, to: self.end)
        return NSMakeRange(location, length)
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: font], context: nil)
        
        // TODO: Remove the temp solution to add 20 pts for incorrect calculation of height
        return ceil(boundingBox.height) + 20
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UIApplication {
    
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}
