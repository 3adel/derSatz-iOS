//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import UIKit

/**
 *  CollectionViewSectionLayout is a protocol which the layout object of each section conforms to. The layout object is responsible for calculating the total content height of the section, and the frames for the header and each item in the section.
 */
public protocol CollectionViewSectionLayout {
    var sectionIndex: Int { get set }
    
    weak var collectionView: UICollectionView? { get }
    weak var dataSource: CollectionViewDataSource? { get set }
    weak var section: ListSection? { get set }
    
    var scrollDirection: UICollectionViewScrollDirection { get set }
    /**
     Prepare layout
     */
    func prepare()
    
    func prepareLayout(after index: Int, calculateDynamicSize: Bool)
    
    func calculateDynamicSizeIfNeeded(at index: Int)
    
    /**
     Get the total height of the content, including the header and all of the cells
     
     - returns: Content height of the section
     */
    func contentScrollSize() -> CGFloat
    
    /**
     Get the frame of the header in the section. The y origin of the frame is relative, and does not take into account the content height of the sections before
     
     - returns: Frame of the header
     */
    func frameForHeader() -> CGRect
    
    /**
     Get the frame of the footer in the section. The y origin of the frame is relative, and does not take into account the content height of the sections before
     
     - returns: Frame of the footer
     */
    func frameForFooter() -> CGRect
    
    /**
     Get the frame for the item at index. The y origin of the frame is relative, and does not take into account the content height of the sections before
     
     - parameter index: Index of the item
     
     - returns: Frame of the item
     */
    func frameForItem(atIndex index: Int) -> CGRect
}
