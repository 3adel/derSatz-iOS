//
//  FeatureConfig.swift
//  Texture
//
//  Created by Halil Gursoy on 28.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import Foundation

enum AppFeature {
    case urlSearch
    case savedArticles
    case openInExtension
    
    static func features(for inAppProduct: DerSatzIAProduct) -> [AppFeature] {
        switch inAppProduct {
        case .premium: return [.urlSearch, .savedArticles, .openInExtension]
        }
    }
    
    var parentProduct: DerSatzIAProduct {
        switch self {
        case .openInExtension, .savedArticles, .urlSearch: return .premium
        }
    }
}

enum FeatureStatus {
    case enabled
    case trial(Int)
    case disabled(String)
}

class FeatureConfig {
    static let shared = FeatureConfig()
    
    private let userDefaults: UserDefaults
    private let iapService: IAPService
    private var enabledFeatures: Set<AppFeature> = []
    private var featuresInTrial: Set<AppFeature> = []
    
    
    private init(userDefaults: UserDefaults = .shared) {
        self.iapService = .shared
        self.userDefaults = userDefaults
        setup()
    }
    
    func update(feature: AppFeature, isEnabled: Bool) {
        if isEnabled {
            enabledFeatures.insert(feature)
        } else {
            enabledFeatures.remove(feature)
        }
    }
    
    func status(for feature: AppFeature) -> FeatureStatus {
        if isFeatureEnabled(feature) {
            return .enabled
        } else if isFeatureInTrial(feature) {
            let product = feature.parentProduct
            let daysLeft = iapService.daysRemainingInTrial(for: product)
            return .trial(daysLeft)
        } else {
            let errorMessage = "You need to be a Premium user to be able to use this feature"
            return .disabled(errorMessage)
        }
    }
    
    func isFeatureEnabled(_ feature: AppFeature) -> Bool {
        updateFeatures()
        return enabledFeatures.contains(feature)
    }
    
    func isFeatureInTrial(_ feature: AppFeature) -> Bool {
        updateFeatures()
        return featuresInTrial.contains(feature)
    }
    
    func shouldShowPromotion(for feature: AppFeature) -> Bool {
        let product = feature.parentProduct
        let previousUsage = userDefaults.value(forKey: product.didUseProductUserDefaultsKey) as? Int ?? 0
        let firstUsageLimit = 5
        
        guard previousUsage > firstUsageLimit else { return false }
        
        let interval = 10
        
        guard let date = userDefaults.value(forKey: UserDefaults.Key.promotionLastShowDate.rawValue + product.trialStartDateUserDefaultsKey) as? Date else { return true }
        
        return (Date().timeIntervalSince1970 - date.timeIntervalSince1970) - interval.days > 0
    }
    
    func didShowPromotion(for feature: AppFeature) {
        let product = feature.parentProduct
        let key = UserDefaults.Key.promotionLastShowDate.rawValue + product.trialStartDateUserDefaultsKey
        
        userDefaults.set(Date(), forKey: key)
    }
    
    func didUse(_ feature: AppFeature) {
        let product = feature.parentProduct
        iapService.register(products: [product])
        
        let currentUsage = userDefaults.value(forKey:  product.didUseProductUserDefaultsKey) as? Int ?? 0
        
        userDefaults.set(currentUsage + 1, forKey: product.didUseProductUserDefaultsKey)
    }
    
    func setup() {
        iapService.updateStatus(for: DerSatzIAProduct.allProducts)
    }
    
    private func updateFeatures() {
        let allProducts = DerSatzIAProduct.allProducts
        self.enabledFeatures = Set(allProducts.filter ({ iapService.purchasedProducts.contains($0) }).flatMap { AppFeature.features(for: $0) })
        
        self.featuresInTrial = Set(allProducts.filter ({ iapService.productsInTrial.contains($0) }).flatMap
            { AppFeature.features(for: $0) })
    }
}
