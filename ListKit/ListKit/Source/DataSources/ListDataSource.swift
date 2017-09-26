//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

public class ListDataSource: NSObject {
    weak var listView: ListViewProtocol!
    var sections: [ListSection] = []
    
    public var isAccordion: Bool = false
    
    public var expandedSection: Int?
    
    public var isExpanded: Bool {
        return expandedSection != nil
    }
    
    public var showSectionSeparators: Bool = false
    public var separatorColor: UIColor = .white
    public var separatorInsets: UIEdgeInsets = .zero
    
    public var onExpandedSectionDidChangeTo: ((_: ListSection?) -> ())?
    public var onScrollDidEnd: (()->())?
    public var onItemShown: ((IndexPath) -> ())?
    public var onScroll: (() -> Void)?
    
    var pagingSection: ListSection? { return sections.last }
    
    var loadMoreView: LoadMoreView?
    var features: [ListFeature] = []
    
    init(sections: [ListSection], listView: ListViewProtocol?) {
        self.sections = sections
        self.listView = listView
    }
    
    public func reloadList(animated: Bool = false) {
        listView.reloadData(animated: animated)
    }
    
    public func reloadItems(at indexes: [Int], in section: Int) {
        let indexPaths = indexes.map { IndexPath(item: $0, section: section) }
        listView.reloadData(at: indexPaths)
    }
    
    public func update(sections: [ListSection], animated: Bool = false) {
        self.sections.removeAll()
        sections.enumerated().forEach { section in
            section.element.index = section.offset
            section.element.dataSource = self
            
            self.sections.append(section.element)
        }
        
        isPagingEnabledDidChange(to: pagingSection?.isPagingEnabled ?? false)
        
        reloadList(animated: animated)
    }

    public func add(listSection: ListSection, animated: Bool = false) {
        listSection.dataSource = self
        listSection.index = sections.count
        
        isPagingEnabledDidChange(to: listSection.isPagingEnabled)
        
        self.sections.append(listSection)
        reloadList(animated: animated)
    }
    
    public func didAddItems(at indexPaths: [IndexPath]) {
        listView.insertItems(at: indexPaths)
    }
    
    public func didUpdateSection(at index: Int) {
        listView.reload(sections: [index])
    }
    
    public func update(viewModels: [Any]) {
        sections[0].viewModels = viewModels
        reloadList()
    }
    
    public func update(viewModelAt index: Int, viewModel: Any) {
        sections[0].viewModels[index] = viewModel
        reloadList()
    }
    
    public func add(listFeature: ListFeature) {
        features.append(listFeature)
    }
    
    func makeCell(at indexPath: IndexPath) -> ListViewComponent? {
        let section = sections[indexPath.section]
        let viewModel = section.viewModels[indexPath.row]
        
        let cellIdentifier = section.identifier(forCellAt: indexPath.row)
        
        if cellIdentifier != WrapperCollectionCell.Identifier,
            UINib.doesExist(withName: cellIdentifier) {
            
            listView.registerCell(withIdentifier: cellIdentifier)
        }
        let actionableComponent: ListViewComponent
        
        guard let cell = listView.makeReusableCell(withIdentifier: cellIdentifier, at: indexPath) else { return nil }
        
        if let wrapperCell = cell as? WrapperCollectionCell,
            let customView = makeView(at: indexPath) {
            wrapperCell.set(customView: customView)
            wrapperCell.tag = indexPath.row
            actionableComponent = customView
        } else {
            actionableComponent = cell
        }
        
        let onSelect = section.isMultiLayer ? section.onSelect : nil
        cell.update(withViewModel: viewModel, onSelect: onSelect)
        
        section.cellActionCallbacks.forEach { (action, callback) in
            actionableComponent.register(action: action, callback: callback)
        }
        
        features.forEach { feature in
            feature.setup(with: cell, at: indexPath)
        }
        
        return cell
    }
    
    func makeView(at indexPath: IndexPath) -> ListViewComponent? {
        let section = sections[indexPath.section]
        
        let viewIdentifier = section.viewIdentifier(forCellAt: indexPath.row)
        let view = Bundle.main.loadNibNamed(viewIdentifier, owner: self, options: nil)?[0] as? ListViewComponent
        return view
    }
    
    func makeHeader(at indexPath: IndexPath) -> ListViewComponent? {
        let section = sections[indexPath.section]
        
        let viewModel: Any = section.headerViewModel ?? section.title
        
        guard let headerIdentifier = section.headerIdentifier else { return nil }
        
        if  UINib.doesExist(withName: headerIdentifier) {
            listView.registerHeader(withIdentifier: headerIdentifier)
        }
        
        guard let header = listView.makeReusableHeader(withIdentifier: headerIdentifier, at: indexPath) else { return nil }
        
        header.update(withViewModel: viewModel)
        
        section.headerActionCallbacks.forEach { (action, callback) in
            header.register(action: action, callback: callback)
        }
        
        return header
    }
    
    func makeFooter(at indexPath: IndexPath) -> ListViewComponent? {
        if let pagingSection = pagingSection,
            pagingSection.isPagingEnabled {
            guard let loadMoreView =  makeFooterForLoadMore(at: indexPath) as? LoadMoreView else { return nil }
            
            self.loadMoreView = loadMoreView
            startPaginationAnimation()
            pagingSection.getNextPage?()
            
            return loadMoreView
        }
        
        if showSectionSeparators {
            return listView.makeReusableFooter(withIdentifier: SeparatorFooterView.Identifier, at: indexPath)
        }
        
        let section = sections[indexPath.section]
        
        guard let footerIdentifier = section.footerIdentifier,
            let footerViewModel = section.footerViewModel,
            let footer = listView.makeReusableFooter(withIdentifier: footerIdentifier, at: indexPath) else { return nil }
        
        footer.update(withViewModel: footerViewModel)
        
        section.footerActionCallbacks.forEach { (action, callback) in
            footer.register(action: action, callback: callback)
        }
        
        return footer
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sections[section].viewModels.count
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func getSize(forCellAt indexPath: IndexPath) -> ViewComponentSizeProtocol {
        return sections[indexPath.section].size(forCellAt: indexPath.row)
    }
    
    func getSize(forHeaderInSection sectionIndex: Int) -> ViewComponentSizeProtocol {
        return sections[sectionIndex].headerSize ?? ViewComponentSize.zero
    }
    
    func getSize(forFooterInSection sectionIndex: Int) -> ViewComponentSizeProtocol {
        if let pagingSection = pagingSection,
            pagingSection.index == sectionIndex,
            pagingSection.isPagingEnabled,
            pagingSection.hasNextPage {
            return ViewComponentSize(height: 44)
        }
        
        if showSectionSeparators  {
            return sections.count == sectionIndex + 1 ? ViewComponentSize.zero : ViewComponentSize(size: CGSize(width: 1, height: 1), widthType: .relative, heightType: .absolute, edgeInsets: separatorInsets)
        } else {
            return sections[sectionIndex].footerSize ?? ViewComponentSize.zero
        }
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        let section = sections[indexPath.section]
        section.onSelect?(indexPath)
    }
    
    func isPagingEnabledDidChange(to isPagingEnabled: Bool) {
        if isPagingEnabled {
            listView.registerFooter(withClass: LoadMoreView.self, identifier: LoadMoreView.Identifier) 
        }
    }
}

extension ListDataSource {
    func makeFooterForLoadMore(at indexPath: IndexPath) -> ListViewComponent? {
        return listView.makeReusableFooter(withIdentifier: LoadMoreView.Identifier, at: indexPath)
    }
    
    public func startPaginationAnimation() {
        loadMoreView?.startAnimating()
    }
    
    public func stopPaginationAnimation() {
        loadMoreView?.stopAnimating()
    }
}

extension ListDataSource {
    func list(_ listView: ListViewProtocol, didScrollTo offset: CGPoint) {
        features.forEach { $0.list(didScrollTo: offset) }
        onScroll?()
    }
}
