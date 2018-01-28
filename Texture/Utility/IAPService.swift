//
//  File.swift
//  Texture
//
//  Created by Halil Gursoy on 28.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import Foundation
import StoreKit

enum DerSatzIAProduct: IAProduct {
    case premium
    
    var sku: String {
        switch self {
        case .premium: return "com.dersatz.premium"
        }
    }
}

protocol IAProduct {
    var sku: String { get }
}

extension IAProduct {
    static func ==(lhs: IAProduct, rhs: IAProduct) -> Bool {
        return lhs.sku == rhs.sku
    }
}

extension Array where Element == IAProduct {
    func contains(_ element: Element) -> Bool {
        return contains { $0.sku == element.sku }
    }
}

class IAPService: NSObject {
    let userDefaults: UserDefaults
    var purchasedProducts: [IAProduct] = []
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func updateStatus(for products: [IAProduct], completion: (() -> Void)?) {
        purchasedProducts = products.filter { userDefaults.bool(forKey: $0.sku) }
        completion?()
    }
    
    func buy(product: IAProduct) {
        userDefaults.set(true, forKey: product.sku)
    }
}
