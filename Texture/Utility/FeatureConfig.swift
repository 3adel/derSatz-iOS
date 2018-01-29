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
    
    private let iapService: IAPService
    private var enabledFeatures: Set<AppFeature> = []
    private var featuresInTrial: Set<AppFeature> = []
    
    
    private init() {
        self.iapService = .shared
        setup(with: self.iapService)
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
        return enabledFeatures.contains(feature)
    }
    
    func isFeatureInTrial(_ feature: AppFeature) -> Bool {
        return featuresInTrial.contains(feature)
    }
    
    func shouldShowPromotion(for feature: AppFeature) -> Bool {
        let interval = 10
        let product = feature.parentProduct
        let daysPast = iapService.trialDays - iapService.daysRemainingInTrial(for: product)
        
        let maxShowCount = daysPast/interval + 1
        let currentShowCount = UserDefaults.standard.integer(forKey: UserDefaults.Key.promotionShowCount.rawValue + product.userDefaultsKey)
        return currentShowCount < maxShowCount
    }
    
    func didShowPromotion(for feature: AppFeature) {
        let product = feature.parentProduct
        let key = UserDefaults.Key.promotionShowCount.rawValue + product.userDefaultsKey
        let currentShowCount = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(currentShowCount + 1, forKey: key)
    }
    
    private func setup(with iapService: IAPService) {
        let allProducts = [DerSatzIAProduct.premium]
        iapService.updateStatus(for: allProducts) {
            self.enabledFeatures = Set(allProducts.filter ({ iapService.purchasedProducts.contains($0) }).flatMap { AppFeature.features(for: $0) })
            
            self.featuresInTrial = Set(allProducts.filter ({ iapService.productsInTrial.contains($0) }).flatMap
                { AppFeature.features(for: $0) })
        }
    }
}