//
//  Identifiable .swift
//  LoungeFoundation
//
//  Created by Joachim Deelen on 09.10.15.
//  Copyright © 2015 Zalando. All rights reserved.
//

import UIKit

/**
 Types that implement this protocol are able to
 identify themselves by querying their static
 Identifier-Property
 
 The default implementation returns the name
 of the type the instance was created from.
 
 UIView and UIViewController are both extended
 to implement this protocol
 */
protocol Identifiable {
    
    /**
     The Identifier of the type.
     Defaults to the name of the type
     */
    static var Identifier:String! {get}
}

// Default implementation
extension Identifiable {
    
    /**
     The Identifier of the type.
     Defaults to the name of the type
     */
    static var Identifier:String! { return "\(self)" }  //TODO: Use String(self) instead for more readability
}


extension UIViewController: Identifiable {
}

extension UIView: Identifiable {
}

protocol NibCell {
    static var Nib: String { get }
}

extension NibCell {
    static var Nib: String { return "\(self)" }
}

extension UITableViewCell: NibCell {
}

extension UICollectionViewCell: NibCell {
}
