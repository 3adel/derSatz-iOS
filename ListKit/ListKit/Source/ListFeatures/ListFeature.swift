//
//  Copyright © 2017 Zalando. All rights reserved.
//

import Foundation

public protocol ListFeature {
    func setup(with listViewComponent: ListViewComponent, at indexPath: IndexPath)
    func list(didScrollTo offset: CGPoint)
    func process(attributesForItem attributes: UICollectionViewLayoutAttributes, at indexPath: IndexPath, yOffset: CGFloat) -> UICollectionViewLayoutAttributes
}

public extension ListFeature {
    func setup(with listViewComponent: ListViewComponent, at indexPath: IndexPath) {}
    func list(didScrollTo offset: CGPoint) {}
    func process(attributesForItem attributes: UICollectionViewLayoutAttributes, at indexPath: IndexPath, yOffset: CGFloat) -> UICollectionViewLayoutAttributes { return attributes }
}
