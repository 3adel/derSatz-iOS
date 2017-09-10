//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout {
    
    unowned var dataSource: CollectionViewDataSource
    
    var stickyHeaderCoordinator = StickyHeaderCoordinator(stickyHeaders: [:])
    
    public var scrollDirection: UICollectionViewScrollDirection = .vertical {
        didSet {
            prepare()
        }
    }
    
    init(dataSource: CollectionViewDataSource) {
        self.dataSource = dataSource
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Initializing from Storyboard not supported")
    }
    
    override func prepare() {
        super.prepare()
        dataSource.sections.forEach {
            $0.layout.scrollDirection = scrollDirection
            $0.layout.prepare()
        }
    }
    
    func numberOfSections() -> Int {
        return dataSource.sections.count
    }
    
    func section(at index: Int) -> ListSection {
        return dataSource.sections[index]
    }
    
    /**
     Get the absolute frame for the section with the relative frame
     
     - parameter index: THe index of the frame
     - parameter frame: The relative frame of the section
     
     - returns: The absolute frame
     */
    func absoluteFrameForSection(atIndex index: Int, withRelativeFrame frame: CGRect) -> CGRect {
        var scrollOffset = frame.startPoint(with: scrollDirection, in: .scroll)
        
        // Sum the height of each section that is before the section atIndex, to find the absolute y origin of this section
        
        scrollOffset += dataSource.sections[0..<index].reduce(0) { scrollSize, section in scrollSize + section.layout.contentScrollSize()}
        
        let layoutOrigin = frame.startPoint(with: scrollDirection, in: .layout)
        let origin = CGPoint(layoutOrigin: layoutOrigin, scrollOrigin: scrollOffset, scrollDirection: scrollDirection)
        return CGRect(origin: origin, size: frame.size)
    }
    
    /**
     Get the frame of the section. This method calculates the relative frame of the section and uses this frame to get the absolute frame. And it returns the absolute frame.
     
     - parameter index: Index of the section
     
     - returns: Frame of the section
     */
    func frameOfSection(atIndex index: Int) -> CGRect {
        let collectionViewSize = collectionView?.frame.size ?? .zero
        let layoutSize = collectionViewSize.dimension(with: scrollDirection, in: .layout)
        
        let size = CGSize(layoutDimension: layoutSize,
                          scrollDimension: section(at: index).layout.contentScrollSize(), scrollDirection: scrollDirection)
        
        let frame = CGRect(origin: .zero, size: size)
        return absoluteFrameForSection(atIndex: index, withRelativeFrame: frame)
    }
    
    /**
     Get the frame of the section which intersects with the given frame
     
     - parameter index: Index of the section
     - parameter frame: Frame which the intersecting frame of the section is being calculated
     
     - returns: Intersection frame
     */
    func intersectingFrameOfSection(atIndex index: Int, withFrame frame: CGRect) -> CGRect {
        return frameOfSection(atIndex: index).intersection(frame)
    }
    
    //MARK: UICollectionViewlayout
    override var collectionViewContentSize : CGSize {
        var scrollSize: CGFloat = 0
        
        // Calculate the total height of all the sections
        dataSource.sections.forEach { scrollSize += $0.layout.contentScrollSize() /*+ $0.edgeInsets.top + $0.edgeInsets.bottom */}
        
        let collectionViewSize = collectionView?.frame.size ?? .zero
        
        let layoutDimension = collectionViewSize.dimension(with: scrollDirection, in: .layout)
        return CGSize(layoutDimension: layoutDimension, scrollDimension: scrollSize, scrollDirection: scrollDirection)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        guard let collectionView = collectionView else { return attributes }
        
        // Go through each section and each item in the sections and find the items that intersects with the given frame, and return the attributes for those items
        
        dataSource.sections.enumerated().forEach { (sectionIndex, section) in
            if let attributesForHeader = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: sectionIndex)) ,
                attributesForHeader.frame.size != .zero {
                attributes.append(attributesForHeader)
            }
            
            if let attributesForFooter = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: sectionIndex)),
                attributesForFooter.frame.size != .zero {
                attributes.append(attributesForFooter)
            }
            
            // Get the attributes for the items in the section that intersects with the frame
            for itemIndex in 0..<collectionView.numberOfItems(inSection: sectionIndex) {
                guard let attributesForItem = layoutAttributesForItem(at: IndexPath(item: itemIndex, section: sectionIndex)) else { continue }
                if rect.intersects(attributesForItem.frame) {
                    attributes.append(attributesForItem)
                }
            }
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let selectedSection = section(at: indexPath.section)
        
        let attributesForItem = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let frame = selectedSection.layout.frameForItem(atIndex: indexPath.row)
        attributesForItem.frame = absoluteFrameForSection(atIndex: indexPath.section, withRelativeFrame: frame)
        
        let yOffset = collectionView?.contentOffset.y ?? 0
        
        let modifiedAttributes: UICollectionViewLayoutAttributes = dataSource.features.reduce(attributesForItem) { attributes, feature in
            return feature.process(attributesForItem: attributes, at: indexPath, yOffset: yOffset)
        }
        
        return modifiedAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        let layout = section(at: indexPath.section).layout
        let frame = elementKind == UICollectionElementKindSectionHeader ? layout.frameForHeader() : layout.frameForFooter()
        
        attributes.frame = absoluteFrameForSection(atIndex: indexPath.section, withRelativeFrame: frame)
        
        let yOffset = collectionView?.contentOffset.y ?? 0
        
        return stickyHeaderCoordinator.process(attributesForHeader: attributes, section: indexPath.section, yOffset: yOffset)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // This method always returns true as the collectionViewLayout should always be invalidated when the bounds change
        return true
    }
    
    private let animationCellHeight: CGFloat = 10 // There is a glitch happens when making it zero, which is the cells disappears with opening for the second time
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.frame.size.height = animationCellHeight
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        attributes?.frame.size.height = animationCellHeight
        return attributes
    }
}
