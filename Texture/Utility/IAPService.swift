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
    
    var userDefaultsKey: String {
        return UserDefaults.Key.trialStartDate.rawValue + sku
    }
}

protocol IAProduct {
    var sku: String { get }
    var userDefaultsKey: String { get }
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
    var productsInTrial: [IAProduct] = []
    
    var trialDays = 30
    
    static let shared = IAPService()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func register(products: [IAProduct]) {
        products.forEach {
            guard userDefaults.value(forKey: $0.userDefaultsKey) as? Date == nil else { return }
            userDefaults.set(Date(), forKey: $0.userDefaultsKey)
        }
    }
    
    func updateStatus(for products: [IAProduct], completion: (() -> Void)?) {
        purchasedProducts = products.filter { userDefaults.bool(forKey: $0.sku) }
        productsInTrial = products
        
        completion?()
    }
    
    func daysRemainingInTrial(for product: IAProduct) -> Int {
        guard let date = userDefaults.value(forKey: product.userDefaultsKey) as? Date else { return trialDays }
        
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: date)
        let date2 = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        let daysPast = components.day ?? 0
        return trialDays - daysPast
    }
    
    func minutesRemainingInTrial(for product: IAProduct) -> Int {
        guard let date = userDefaults.value(forKey: product.userDefaultsKey) as? Date else { return trialDays }
        
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.minute], from: date, to: Date())
        let minutesPast = components.minute ?? 0
        return Int(trialDays.minutes - minutesPast.minutes)
    }
    
    func buy(product: IAProduct) {
        userDefaults.set(true, forKey: product.sku)
    }
}
