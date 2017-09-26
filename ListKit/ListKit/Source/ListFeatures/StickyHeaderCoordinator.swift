//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

typealias ProgressCallback = (CGFloat) -> ()

public struct StickyHeaderInfo {
    let thresholdFromEnd: CGFloat
    let callback: ProgressCallback?
    let shouldShowShadowForHeader: Bool
    let shouldStick: Bool
    var end: CGFloat
    var headerView: UIView?
    var isAtTop: Bool
    var currentPercentageOverThreshold: CGFloat
    
    init(thresholdFromEnd: CGFloat = 64,  end: CGFloat = -1, shouldShowShadowForHeader: Bool = false, shouldStick: Bool = true, headerView: UIView? = nil, callback: ProgressCallback? = nil) {
        self.thresholdFromEnd = thresholdFromEnd
        self.end = end
        self.shouldShowShadowForHeader = shouldShowShadowForHeader
        self.shouldStick = shouldStick
        self.headerView = headerView
        self.callback = callback
        
        self.isAtTop = false
        self.currentPercentageOverThreshold = 0
    }
}

class StickyHeaderCoordinator {
    var stickyHeaders: [Int : StickyHeaderInfo] = [:]
    
    var isStickyHeaderAtTop: Bool {
        get {
            return stickyHeaders.values.first?.isAtTop ?? false
        }
    }
    
    init(stickyHeaderSection: Int, thresholdFromEnd: CGFloat, shouldShowShadowForHeader: Bool = false,  callback: @escaping ProgressCallback) {
        let stickyHeaderInfo = StickyHeaderInfo(thresholdFromEnd: thresholdFromEnd,
                                                callback: callback)
        
        stickyHeaders[stickyHeaderSection] = stickyHeaderInfo
    }
    
    init(stickyHeaders: [Int: StickyHeaderInfo]) {
        self.stickyHeaders = stickyHeaders
    }
    
    func currentPercentageOverThreshold(for section: Int) -> CGFloat {
        return stickyHeaderInfo(at: section)?.currentPercentageOverThreshold ?? 0
    }
    
    func set(headerView: UIView, at section: Int) {
        stickyHeaders[section]?.headerView = headerView
    }
    
    func collectionViewDidScroll(to offset: CGPoint) {
        let yOffset = offset.y
        
        stickyHeaders.keys.forEach {
            process(yOffset: yOffset, forSection: $0)
        }
    }
    
    private func process(yOffset: CGFloat, forSection section: Int) {
        guard var stickyHeader = stickyHeaders[section],
            stickyHeader.end >= 0
            else { return }
        
        // Y offset of the start of the sticky header animation
        let thresholdOffset = stickyHeader.end - stickyHeader.thresholdFromEnd
        
        let rateOverThreshold: CGFloat
        
        // If Y offset is in the animation range of the sticky header
        if yOffset >= thresholdOffset && yOffset <= stickyHeader.end {
            let amountOverThreshold = yOffset - thresholdOffset
            rateOverThreshold = amountOverThreshold / (stickyHeader.end - thresholdOffset)
        } else { // If y offset is outside the animation range of the sticky header, rate is either 0 or 1
            rateOverThreshold = yOffset < thresholdOffset ? 0 : 1
        }
        
        // Show shadow underneath the header based on the rate over threshold, if needed
        if stickyHeader.shouldShowShadowForHeader {
            let finalOpacity: CGFloat = 0.08
            
            let currentOpacity = finalOpacity * rateOverThreshold
            
            stickyHeader.headerView?.layer.shadowOffset = CGSize(width: 0, height: 3)
            stickyHeader.headerView?.layer.shadowColor = UIColor.black.cgColor
            stickyHeader.headerView?.layer.shadowOpacity = Float(currentOpacity)
            stickyHeader.headerView?.layer.shadowRadius = 5
            stickyHeader.headerView?.layer.masksToBounds = false
        }
        
        stickyHeader.isAtTop = rateOverThreshold >= 0.9
        stickyHeader.currentPercentageOverThreshold = rateOverThreshold
        
        stickyHeader.callback?(rateOverThreshold)
        
        stickyHeaders[section] = stickyHeader
    }
    
    /**
     Calculate y offset of the sticky header
     */
    func process(attributesForHeader attributes: UICollectionViewLayoutAttributes, section: Int, yOffset: CGFloat) -> UICollectionViewLayoutAttributes {
        guard var stickyHeaderInfo = stickyHeaderInfo(at: section) else { return attributes }
        
        stickyHeaderInfo.end =  stickyHeaderInfo.shouldStick ? attributes.frame.origin.y : attributes.frame.height
        stickyHeaders[section] = stickyHeaderInfo
        
        if stickyHeaderInfo.shouldStick {
            attributes.frame.origin.y = max(yOffset + 64, attributes.frame.origin.y)
            attributes.zIndex = 1024
        }
        
        return attributes
    }
    
    private func stickyHeaderInfo(at section: Int) -> StickyHeaderInfo? {
        return stickyHeaders[section]
    }
}

