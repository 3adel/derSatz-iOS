//
//  HelperFunctions.swift
//  Texture
//
//  Created by Halil Gursoy on 26.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import Foundation

public func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                                  execute: closure)
}
