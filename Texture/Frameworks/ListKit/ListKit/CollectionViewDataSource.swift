//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

public class CollectionViewDataSource: ListDataSource {
    override var listView: ListView! {
        didSet {
            setupCollectionView()
        }
    }
    
    override public var showSectionSeparators: Bool {
        didSet {
            registerSeparator()
        }
    }
    
    public init(cellIdentifier: String,
                     collectionView: UICollectionView? = nil,
                     viewModels: [Any] = [],
                     actions: Any? = nil,
                     sizes: [ViewComponentSize] = [],
                     headerIdentifier: String? = nil,
                     footerIdentifier: String? = nil,
                     onSelect: ListSelectionClosure? = nil) {
        super.init(cellIdentifier: cellIdentifier,
                  listView: collectionView,
                  viewModels: viewModels,
                  actions: actions,
                  sizes: sizes,
                  headerIdentifier: headerIdentifier,
                  footerIdentifier: footerIdentifier,
                  onSelect: onSelect)

        
        setupCollectionView()
    }
    
    public convenience init(cellIdentifier: String,
                     collectionView: UICollectionView? = nil,
                     viewModels: [Any] = [],
                     actions: Any? = nil,
                     size: ViewComponentSize = .zero,
                     headerIdentifier: String? = nil,
                     footerIdentifier: String? = nil,
                     onSelect: ListSelectionClosure? = nil) {
        self.init(cellIdentifier: cellIdentifier,
                  collectionView: collectionView,
                  viewModels: viewModels,
                  actions: actions,
                  sizes: [size],
                  headerIdentifier: headerIdentifier,
                  footerIdentifier: footerIdentifier,
                  onSelect: onSelect)
    }
    
    public init(viewIdentifier: String,
                collectionView: UICollectionView? = nil,
                viewModels: [Any] = [],
                actions: Any? = nil,
                sizes: [ViewComponentSize] = [],
                headerIdentifier: String? = nil,
                footerIdentifier: String? = nil,
                onSelect: ListSelectionClosure? = nil) {
        super.init(viewIdentifier: viewIdentifier,
                   listView: collectionView,
                   viewModels: viewModels,
                   actions: actions,
                   sizes: sizes,
                   headerIdentifier: headerIdentifier,
                   footerIdentifier: footerIdentifier,
                   onSelect: onSelect)
        setupCollectionView()
    }
    
    public convenience init(viewIdentifier: String,
                            collectionView: UICollectionView? = nil,
                            viewModels: [Any] = [],
                            actions: Any? = nil,
                            size: ViewComponentSize = .zero,
                            headerIdentifier: String? = nil,
                            footerIdentifier: String? = nil,
                            onSelect: ListSelectionClosure? = nil) {
        self.init(viewIdentifier: viewIdentifier,
                  collectionView: collectionView,
                  viewModels: viewModels,
                  actions: actions,
                  sizes: [size],
                  headerIdentifier: headerIdentifier,
                  footerIdentifier: footerIdentifier,
                  onSelect: onSelect)
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
        
        collectionView.register(WrapperCollectionCell.self, forCellWithReuseIdentifier: WrapperCollectionCell.Identifier)
    }
    
    func registerSeparator() {
        guard let collectionView = listView as? UICollectionView else { return }
        collectionView.register(SeparatorFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: SeparatorFooterView.Identifier)
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
        let viewComponentSize = getSize(forCellAt: indexPath)
        let width = viewComponentSize.widthType == .relative ? collectionView.frame.width * viewComponentSize.size.width : viewComponentSize.size.width
        var height = viewComponentSize.heightType == .relative ? collectionView.frame.height * viewComponentSize.size.height : viewComponentSize.size.height
        
        height -= collectionView.contentInset.top - collectionView.contentInset.bottom
        
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let viewComponentSize = getSize(forHeaderInSection: section)
        return viewComponentSize.calculateActualSize(in: collectionView.frame)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if showSectionSeparators && sections.count == section + 1 {
            return .zero
        } else {
            let viewComponentSize = getSize(forFooterInSection: section)
            return viewComponentSize.calculateActualSize(in: collectionView.frame)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let listSection = sections[section]
        return listSection.edgeInsets ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let listSection = sections[section]
        return listSection.interitemSpacing
    }
}
