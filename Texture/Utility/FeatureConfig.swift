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
}

enum FeatureStatus {
    case enabled
    case disabled(String)
}

class FeatureConfig {
    static let shared = FeatureConfig()
    
    private var enabledFeatures: Set<AppFeature> = []
    
    private init() {}
    
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
        } else {
            let errorMessage = "You need to be a Premium user to be able to use this feature"
            return .disabled(errorMessage)
        }
    }
    
    func isFeatureEnabled(_ feature: AppFeature) -> Bool {
        return enabledFeatures.contains(feature)
    }
    
    private func setup(with iapService: IAPService) {
        let allProducts = [DerSatzIAProduct.premium]
        iapService.updateStatus(for: allProducts) {
            self.enabledFeatures = Set(allProducts.filter ({ iapService.purchasedProducts.contains($0) }).flatMap { AppFeature.features(for: $0) })
        }
    }
}
