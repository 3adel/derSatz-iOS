//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import Foundation

public class StretchyImageHeaderFeature: ListFeature {
    public var section: Int = 0
    
    public init(section: Int) {
        self.section = section
    }
    
    public func process(attributesForItem attributes: UICollectionViewLayoutAttributes, at indexPath: IndexPath, yOffset: CGFloat) -> UICollectionViewLayoutAttributes {
        guard indexPath.row == 0,
            indexPath.section == section,
            yOffset < 0
        else { return attributes }
        
        var frame = attributes.frame
        frame.size.height += abs(yOffset)
        
        frame.origin.y += yOffset
        
        attributes.frame = frame
        return attributes
    }
}
