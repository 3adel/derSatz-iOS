//
//  Copyright © 2017 Zalando. All rights reserved.
//

import Foundation

public class ParallaxImageHeaderFeature: ListFeature {
    public var index: Int = 0
    
    var parallaxImageHeader: ParallaxImageHeader?
    
    public init(index: Int) {
        self.index = index
    }
    
    public func list(didScrollTo offset: CGPoint) {
        let yOffset = offset.y
        
        let initalOffset: CGFloat = 0
        let headerOffset = yOffset > initalOffset ? (yOffset - initalOffset)/2 : 0
        
        parallaxImageHeader?.imageView.transform = CGAffineTransform(translationX: 0, y: headerOffset)
        parallaxImageHeader?.offsetChanged(to: yOffset)
    }
    
    public func setup(with listViewComponent: ListViewComponent, at index: Int) {
        guard let parallaxImageHeader = listViewComponent as? ParallaxImageHeader,
            self.index == index else { return }
        
        self.parallaxImageHeader = parallaxImageHeader
    }
}

public protocol ParallaxImageHeader {
    var imageView: UIImageView { get }
    
    func offsetChanged(to y: CGFloat)
}

public extension ParallaxImageHeader {
    func offsetChanged(to y: CGFloat) {}
}

