//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

public class CollectionViewDataSource: ListDataSource {
    override var listView: ListViewProtocol! {
        didSet {
            setupCollectionView()
        }
    }
    
    var collectionView: UICollectionView {
        return listView as! UICollectionView
    }
    
    override public var showSectionSeparators: Bool {
        didSet {
            registerSeparator()
        }
    }
    
    public init(sections: [ListSection], collectionView: UICollectionView) {
        super.init(sections: sections, listView: collectionView)
        
        setupCollectionView()
    }
    
    public convenience init(collectionView: UICollectionView) {
        self.init(sections: [], collectionView: collectionView)
    }
    
    func setupCollectionView() {
        guard let collectionView = listView as? UICollectionView else { return }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = CollectionViewLayout(dataSource: self)
        collectionView.register(WrapperCollectionCell.self, forCellWithReuseIdentifier: WrapperCollectionCell.Identifier)
    }
    
    func registerSeparator() {
        guard let collectionView = listView as? UICollectionView else { return }
        collectionView.register(SeparatorFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: SeparatorFooterView.Identifier)
    }
    
    override public func add(listSection: ListSection, animated: Bool = false) {
        let listSection = setup(listSection: listSection, at: sections.count)
        super.add(listSection: listSection, animated: animated)
    }
    
    override public func update(sections: [ListSection], animated: Bool = false) {
        let sections: [ListSection] = sections.enumerated().map { (index, section) in
            let section = setup(listSection: section, at: index)
            return section
        }
        super.update(sections: sections, animated: animated)
    }
    
    private func setup(listSection: ListSection, at sectionIndex: Int) -> ListSection {
        listSection.layout.dataSource = self
        listSection.layout.sectionIndex = sectionIndex
        listSection.layout.section = listSection
        
        guard let layout = collectionView.collectionViewLayout as? CollectionViewLayout else { return listSection }
        
        layout.stickyHeaderCoordinator.stickyHeaders[sectionIndex] = listSection.stickyHeaderInfo
        
        return listSection
    }
    
}
extension CollectionViewDataSource: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = makeCell(at: indexPath) as? UICollectionViewCell
        return cell ?? UICollectionViewCell()
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let shouldShowSection = section == expandedSection || !isAccordion
        return shouldShowSection ? numberOfItems(in: section) : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryView: ListViewComponent?
        if kind == UICollectionElementKindSectionHeader {
            supplementaryView = makeHeader(at: indexPath)
        } else {
            supplementaryView = makeFooter(at: indexPath)
        }
        
        if var accordionHeader = supplementaryView as? AccordionHeader,
            isAccordion {
            accordionHeader.tag = indexPath.section
            accordionHeader.onDidTap = { [weak self] index  in
                self?.didTapOnHeader(at: index)
            }
        } else
        if let separatorView = supplementaryView as? SeparatorFooterView {
            separatorView.color = separatorColor
            separatorView.setInsets(separatorInsets)
        }
        
        return supplementaryView as? UICollectionReusableView ?? UICollectionReusableView()
    }
    
    func didTapOnHeader(at index: Int) {
        let collectionView = listView as! UICollectionView
        
        let shouldExpand = expandedSection != index
        expandedSection = shouldExpand ? index : nil
        
        let sectionHeight = sections[index].headerSize?.calculateActualSize(in: collectionView.frame).height ?? 0
        let sectionToScroll = CGFloat(shouldExpand ? index + 1 : 0)
        
        let y = sectionToScroll * sectionHeight - collectionView.contentInset.top
        
        let indexPaths = getIndexPaths(for: index)
        
        UIView.animate(withDuration: 0.5) {
            collectionView.contentOffset.y = y
            if shouldExpand {
                collectionView.insertItems(at: indexPaths)
            } else {
                collectionView.deleteItems(at: indexPaths)
            }
            
            collectionView.layoutIfNeeded()
        }
        
        collectionView.isScrollEnabled = !shouldExpand
        
        let newSection: ListSection? = shouldExpand ? sections[index] : nil
        onExpandedSectionDidChangeTo?(newSection)
    }
    
    func getIndexPaths(for section: Int) -> [IndexPath] {
        let indexes = 0...(numberOfItems(in: section)-1)
        return indexes.map { IndexPath(item: $0, section: section) }
    }
    
    public func collapseAccordion() {
        guard let expandedSection = expandedSection else { return }
        
        didTapOnHeader(at: expandedSection)
    }
}

extension CollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionIndex: Int = sections.enumerated().reduce(0) { (result, enumerated) in
            guard let sectionLayout = enumerated.element.layout as? UICollectionViewLayout else { return result }
            return sectionLayout === collectionViewLayout ? enumerated.offset : result
        }
        
        let indexPath = IndexPath(item: indexPath.item, section: sectionIndex)
        
        let viewComponentSize = getSize(forCellAt: indexPath)
        
        var actualSize = viewComponentSize.calculateActualSize(in: collectionView.frame)
        
        actualSize.height -= collectionView.contentInset.top + collectionView.contentInset.bottom
        
        return actualSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let section: Int = sections.enumerated().reduce(0) { (result, enumerated) in
            guard let sectionLayout = enumerated.element.layout as? UICollectionViewLayout else { return result }
            return sectionLayout === collectionViewLayout ? enumerated.offset : result
        }
        
        
        let viewComponentSize = getSize(forHeaderInSection: section)
        return viewComponentSize.calculateActualSize(in: collectionView.frame)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let section: Int = sections.enumerated().reduce(0) { (result, enumerated) in
            guard let sectionLayout = enumerated.element.layout as? UICollectionViewLayout else { return result }
            return sectionLayout === collectionViewLayout ? enumerated.offset : result
        }
        
        if showSectionSeparators && sections.count == section + 1 {
            return .zero
        } else {
            let viewComponentSize = getSize(forFooterInSection: section)
            return viewComponentSize.calculateActualSize(in: collectionView.frame)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let section: Int = sections.enumerated().reduce(0) { (result, enumerated) in
            guard let sectionLayout = enumerated.element.layout as? UICollectionViewLayout else { return result }
            return sectionLayout === collectionViewLayout ? enumerated.offset : result
        }
        
        let listSection = sections[section]
        return listSection.edgeInsets
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let section: Int = sections.enumerated().reduce(0) { (result, enumerated) in
            guard let sectionLayout = enumerated.element.layout as? UICollectionViewLayout else { return result }
            return sectionLayout === collectionViewLayout ? enumerated.offset : result
        }
        
        let listSection = sections[section]
        return listSection.interitemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        onItemShown?(indexPath)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndScroll(scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    
    public func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        onScrollDidEnd?()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.list(listView, didScrollTo: scrollView.contentOffset)
    }
}
