//
//  Extensions.swift
//  RVMP
//
//  Created by Halil Gursoy on 22.11.17.
//  Copyright © 2017 Halil Gursoy. All rights reserved.
//

import Foundation

public func isPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
}

public func isPhone() -> Bool {
    return (!isPad()) && UIApplication.shared.canOpenURL(URL(string: "tel:123")!)
}
