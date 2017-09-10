# Layout

This readme explains how the layouting works for `ListKit`

## Foundation

In order to have full control over the layout and to standardise adding features to the list that require the access to the content offset and/or that need to manipulate layout attributes for list items a custom `UICollectionViewLayout` had to be implemented. Each section object of the list also has it's own layout object which is responsible of determining the frames for the items in that section. The main layout is then responsible of using these section layout objects in order to create the overall layout for the list.

**CollectionViewSectionLayout**
`CollectionViewSectionLayout` is the protocol that each section layout object has to adopt. It provides an interface for the main layout object to get the frames for the items in each section. 

```swift 
public protocol CollectionViewSectionLayout {
    var sectionIndex: Int { get set }
    
    weak var collectionView: UICollectionView? { get }
    weak var dataSource: CollectionViewDataSource? { get set }
    weak var section: ListSection? { get set }
    
    /**
     Prepare layout
     */
    func prepare()
    
    /**
     Get the total height of the content, including the header and all of the cells
     
     - returns: Content height of the section
     */
    func contentHeight() -> CGFloat
    
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
```
**CollectionViewLayout**

`CollectionViewLayout` is the main layout object that is attached to the `UICollectionView`. It's responsible of managing the `layoutAttributes` for each item and the header/footer. It uses the layout object for each section to get the layout info for each section, and calculates the final layout for the list. 

**CollectionViewSectionFlowLayout**

`CollectionViewSectionFlowLayout` is the default layout for each section. It's a simple implementation of the `UICollectionViewFlowLayout`, and conforms to the `CollectionViewSectionLayout`.