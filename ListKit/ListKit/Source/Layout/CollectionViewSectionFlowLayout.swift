//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import UIKit

/** 
 * Simple implementation of the UICollectionViewFlowLayout to be used with CollectionViewSectionLayout
 */
class CollectionViewSectionFlowLayout: CollectionViewSectionLayout {
    weak var dataSource: CollectionViewDataSource?
    weak var section: ListSection?
    
    var sectionIndex: Int = 0
    var scrollDirection: UICollectionViewScrollDirection = .vertical
    
    private var layoutFrames: [CGRect] = []
    private var headerFrame: CGRect = .zero
    private var footerFrame: CGRect = .zero
    private var didCalculateDynamicSizes = false
    
    weak var collectionView: UICollectionView? {
        return dataSource?.collectionView
    }
    
    func prepare() {
        guard let dataSource = dataSource,
            let collectionView = collectionView,
            let section = section
            else { return }
        
        prepareLayoutForHeader(dataSource: dataSource, in: collectionView.frame, scrollDirection: scrollDirection)
        
        prepareLayout(after: 0, calculateDynamicSize: false)
    }
    
    func contentScrollSize() -> CGFloat {
        return footerFrame.endPoint(with: scrollDirection, in: .scroll)
    }
    
    func frameForHeader() -> CGRect {
        return headerFrame
    }
    
    func frameForFooter() -> CGRect {
        return footerFrame
    }
    
    func frameForItem(atIndex index: Int) -> CGRect {
        guard  layoutFrames.count > index else { return .zero }
        return layoutFrames[index]
    }
    
    func prepareLayout(after index: Int, calculateDynamicSize: Bool) {
        guard let dataSource = dataSource,
            let collectionView = collectionView,
            let section = section,
            !didCalculateDynamicSizes && calculateDynamicSize
            else { return }
        
        didCalculateDynamicSizes = true
        
        var itemScrollEndPoint: CGFloat = headerFrame.endPoint(with: scrollDirection, in: .scroll)
        
        layoutFrames.removeAll(after: index)
        let numberOfItems = collectionView.numberOfItems(inSection: sectionIndex)
        
        for index in index..<numberOfItems {
            let lastFrame = layoutFrames.last ?? .zero
            let itemFrame = prepareLayoutForItem(at: index, in: section, in: collectionView.frame, after: lastFrame, scrollDirection: scrollDirection, calculateDynamicSize: calculateDynamicSize)
            layoutFrames.append(itemFrame)
            
            itemScrollEndPoint = max(itemScrollEndPoint, itemFrame.endPoint(with: scrollDirection, in: .scroll))
        }
        
        prepareLayoutForFooter(dataSource: dataSource, in: collectionView.frame, itemScrollEndPoint: itemScrollEndPoint + section.edgeInsets.bottom, scrollDirection: scrollDirection)
    }
    
    func calculateDynamicSizeIfNeeded(at index: Int) {
        guard section?.sizes[index] is DynamicViewComponentSize else { return }
        
        let size = sizeForItem(at: index, calculateDynamicSize: true)
        layoutFrames[index].size = size
        for i in index+1..<layoutFrames.count {
            var origin = layoutFrames[i].origin
            origin.y = layoutFrames[i-1].bottomY
            layoutFrames[i].origin = origin
        }
        footerFrame.origin.y = layoutFrames.last?.bottomY ?? 0
    }
    
    private func sizeForItem(at index: Int, calculateDynamicSize: Bool) -> CGSize {
        let indexPath = IndexPath(item: index, section: sectionIndex)
        
        guard let collectionView = collectionView,
            let viewComponentSize = dataSource?.getSize(forCellAt: indexPath)
            else { return .zero }
        
        var actualSize: CGSize
        
        if calculateDynamicSize,
            let item = section?.item(at: index) as? SelfSizingCell,
            viewComponentSize is DynamicViewComponentSize {
            actualSize = item.calculateActualSize(in: collectionView.frame)
        } else {
            actualSize = viewComponentSize.calculateActualSize(in: collectionView.frame)
        }
        
        actualSize.height -= collectionView.contentInset.top + collectionView.contentInset.bottom
        
        return actualSize
    }
    
    private func prepareLayoutForHeader(dataSource: CollectionViewDataSource, in listFrame: CGRect, scrollDirection: UICollectionViewScrollDirection) {
        let headerSize = dataSource.getSize(forHeaderInSection: sectionIndex)
            .calculateActualSize(in: listFrame)
        
        headerFrame = CGRect(origin: .zero, size: headerSize)
    }
    
    private func prepareLayoutForFooter(dataSource: CollectionViewDataSource, in listFrame: CGRect, itemScrollEndPoint: CGFloat, scrollDirection: UICollectionViewScrollDirection) {
        let footerSize = dataSource.getSize(forFooterInSection: sectionIndex)
            .calculateActualSize(in: listFrame)
        
        let footerOrigin = CGPoint(layoutOrigin: 0, scrollOrigin: itemScrollEndPoint, scrollDirection: scrollDirection)
        footerFrame = CGRect(origin: footerOrigin, size: footerSize)
    }
    
    private func prepareLayoutForItem(at index: Int, in section: ListSection, in listFrame: CGRect, after lastFrame: CGRect, scrollDirection: UICollectionViewScrollDirection, calculateDynamicSize: Bool) -> CGRect {
        let size = sizeForItem(at: index, calculateDynamicSize: calculateDynamicSize)
        let origin: CGPoint
        
        let interitemSpacing = section.interitemSpacing
        let edgeInsets = section.edgeInsets
        
        let lastItemLayoutEndPoint = lastFrame.endPoint(with: scrollDirection, in: .layout) + interitemSpacing
        let edgeInsetLayoutEndPoint = edgeInsets.endPoint(with: scrollDirection, in: .layout)
        
        let sizeLayoutDimension = size.dimension(with: scrollDirection, in: .layout)
        let listSizeLayoutDimension = listFrame.size.dimension(with: scrollDirection, in: .layout)
        let headerScrollEndPoint = headerFrame.endPoint(with: scrollDirection, in: .scroll)
        let edgeInsetScrollStartPoint = edgeInsets.startPoint(with: scrollDirection, in: .scroll)
        let lastItemScrollStartPoint = lastFrame.startPoint(with: scrollDirection, in: .scroll)
        let edgeInsetLayoutStartPoint = edgeInsets.startPoint(with: scrollDirection, in: .layout)
        
        var lastItemScrollEndPoint = lastFrame.endPoint(with: scrollDirection, in: .scroll)
        
        if scrollDirection == .horizontal {
            lastItemScrollEndPoint += interitemSpacing
        }
        
        if lastItemLayoutEndPoint + sizeLayoutDimension + edgeInsetLayoutEndPoint <= listSizeLayoutDimension {
            let scrollOrigin = index == 0 ? headerScrollEndPoint + edgeInsetScrollStartPoint : lastItemScrollStartPoint
            let layoutOrigin = index == 0 ? edgeInsetLayoutStartPoint : lastItemLayoutEndPoint
            
            origin = CGPoint(layoutOrigin: layoutOrigin, scrollOrigin: scrollOrigin, scrollDirection: scrollDirection)
        } else {
            origin = CGPoint(layoutOrigin: edgeInsetLayoutStartPoint, scrollOrigin: lastItemScrollEndPoint, scrollDirection: scrollDirection)
        }
        
        return CGRect(origin: origin, size: size)
    }
}

enum Direction {
    case layout, scroll
}

extension UIEdgeInsets {
    func startPoint(with scrollDirection: UICollectionViewScrollDirection, in direction: Direction) -> CGFloat {
        switch (scrollDirection, direction) {
        case (.vertical, .layout), (.horizontal, .scroll):
            return left
        case (.vertical, .scroll), (.horizontal, .layout):
            return top
        }
    }
    
    func endPoint(with scrollDirection: UICollectionViewScrollDirection, in direction: Direction) -> CGFloat {
        switch (scrollDirection, direction) {
        case (.vertical, .layout), (.horizontal, .scroll):
            return right
        case (.vertical, .scroll), (.horizontal, .layout):
            return bottom
        }
    }
}

extension CGRect {
    func startPoint(with scrollDirection: UICollectionViewScrollDirection, in direction: Direction) -> CGFloat {
        switch (scrollDirection, direction) {
        case (.vertical, .layout), (.horizontal, .scroll):
            return origin.x
        case (.vertical, .scroll), (.horizontal, .layout):
            return origin.y
        }
    }
    
    func endPoint(with scrollDirection: UICollectionViewScrollDirection, in direction: Direction) -> CGFloat {
        switch (scrollDirection, direction) {
        case (.vertical, .layout), (.horizontal, .scroll):
            return rightX
        case (.vertical, .scroll), (.horizontal, .layout):
            return bottomY
        }
    }
}

extension CGSize {
    init(layoutDimension: CGFloat, scrollDimension: CGFloat, scrollDirection: UICollectionViewScrollDirection) {
        if scrollDirection == .vertical {
            self.init(width: layoutDimension, height: scrollDimension)
        } else {
            self.init(width: scrollDimension, height: layoutDimension)
        }
    }
    
    func dimension(with scrollDirection: UICollectionViewScrollDirection, in direction: Direction) -> CGFloat {
        switch (scrollDirection, direction) {
        case (.vertical, .layout), (.horizontal, .scroll):
            return width
        case (.vertical, .scroll), (.horizontal, .layout):
            return height
        }
    }
}

extension CGPoint {
    init(layoutOrigin: CGFloat, scrollOrigin: CGFloat, scrollDirection: UICollectionViewScrollDirection) {
        if scrollDirection == .vertical {
            self.init(x: layoutOrigin, y: scrollOrigin)
        } else {
            self.init(x: scrollOrigin, y: layoutOrigin)
        }
    }
}
