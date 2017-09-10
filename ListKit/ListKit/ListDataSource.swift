//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

public protocol UserAction {
    var identifier: String { get }
}

public extension RawRepresentable where RawValue == String, Self: UserAction {
    var identifier: String {
        return self.rawValue
    }
}

public typealias UserActionCallback = (UIControl) -> ()
public typealias UserActionCallbackPair = (UserAction, UserActionCallback)

public enum ListViewComponentType {
    case cell, header, footer
}

public protocol ListViewComponent {
    func update(withViewModel viewModel: Any)
    func update(withViewModel viewModel: Any, onSelect: ListSelectionClosure?)
    func register(action: UserAction, callback: @escaping UserActionCallback)
}

public extension ListViewComponent {
    //Default implementation
    func update(withViewModel viewModel: Any, onSelect: ListSelectionClosure?) {
        update(withViewModel: viewModel)
    }
    func update(withViewModel viewModel: Any) {}
    func register(action: UserAction, callback: @escaping UserActionCallback) {}
}

public enum ViewComponentSizeType {
    case absolute, relative
}

public protocol ViewComponentSizeProtocol {
    var indentLevel: Int { get }
    func calculateActualSize(in frame: CGRect?) -> CGSize
}

extension ViewComponentSizeProtocol {
    public var indentLevel: Int {
        return 0
    }
}

public struct GridViewComponentSize: ViewComponentSizeProtocol {
    let numberOfItemsPerRow: Int
    let aspectRatio: CGFloat
    let horizontalPadding: CGFloat
    let additionalHeight: CGFloat
    let interitemSpacing: CGFloat
    
    public init(numberOfItemsPerRow: Int,
                aspectRatio: CGFloat = 1,
                horizontalPadding: CGFloat = 0,
                additionalHeight: CGFloat = 0,
                interitemSpacing:CGFloat = 0) {
        self.numberOfItemsPerRow = numberOfItemsPerRow
        self.aspectRatio = aspectRatio
        self.horizontalPadding = horizontalPadding
        self.additionalHeight = additionalHeight
        self.interitemSpacing = interitemSpacing
    }
    
    
    public func calculateActualSize(in frame: CGRect? = nil) -> CGSize {
        guard let frame = frame else { return .zero }
        
        let numberOfItems = CGFloat(numberOfItemsPerRow)
        let allInteritemSpacing = interitemSpacing * (numberOfItems - 1)
        let width = floor((frame.width - (horizontalPadding * 2) - allInteritemSpacing) / numberOfItems)
        
        let height = width / aspectRatio + additionalHeight
        return CGSize(width: width, height: height)

    }
    
    public func byChangingNumberOfItemsPerRow(to numberOfItemsPerRow: Int) -> GridViewComponentSize {
        return GridViewComponentSize(numberOfItemsPerRow: numberOfItemsPerRow,
                                     aspectRatio: aspectRatio,
                                     horizontalPadding: horizontalPadding,
                                     additionalHeight: additionalHeight,
                                     interitemSpacing: interitemSpacing)
    }
}

public struct ViewComponentSize: ViewComponentSizeProtocol {
    public let size: CGSize
    public let additionalSize: CGSize
    public let aspectRatio: CGFloat?
    public let edgeInsets: UIEdgeInsets
    public let indentLevel: Int
    public let widthType: ViewComponentSizeType
    public let heightType: ViewComponentSizeType
    
    public init(size: CGSize, additionalSize: CGSize = .zero, aspectRatio: CGFloat? = nil, widthType: ViewComponentSizeType, heightType: ViewComponentSizeType, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.size = size
        self.additionalSize = additionalSize
        self.aspectRatio = aspectRatio
        self.widthType = widthType
        self.heightType = heightType
        self.edgeInsets = edgeInsets
        self.indentLevel = indentLevel
    }
    
    public init(size: CGSize, additionalSize: CGSize = .zero, type: ViewComponentSizeType = .absolute, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.init(size: size,
                  additionalSize: additionalSize,
                  widthType: type,
                  heightType: type,
                  edgeInsets: edgeInsets)
    }
    
    public init(height: CGFloat, additionalHeight: CGFloat = 0, type: ViewComponentSizeType = .absolute, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.init(size: CGSize(width: 1, height: height),
                  additionalSize: CGSize(width: 0, height: additionalHeight),
                  widthType: .relative,
                  heightType: type,
                  edgeInsets: edgeInsets,
                  indentLevel: indentLevel)
    }
    
    public init(width: CGFloat, widthType: ViewComponentSizeType = .absolute,  aspectRatio: CGFloat, additionalHeight: CGFloat = 0, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.size = CGSize(width: width, height: 0)
        self.additionalSize = CGSize(width: 0, height: additionalHeight)
        self.aspectRatio = aspectRatio
        self.widthType = widthType
        self.heightType = .relative
        self.edgeInsets = edgeInsets
        self.indentLevel = indentLevel
    }
    
    public func calculateActualSize(in frame: CGRect? = nil) -> CGSize {
        if widthType == .absolute && heightType == .absolute {
            return size
        }
        guard let frame = frame else { return .zero }
        
        let width = widthType == .relative ? frame.width * size.width : size.width
        
        let height: CGFloat
        if let aspectRatio = aspectRatio {
            height = width / aspectRatio
        } else {
            height = heightType == .relative ? frame.height * size.height : size.height
        }
        
        return CGSize(width: width + additionalSize.width, height: height + additionalSize.height)
    }
    
    public static let zero: ViewComponentSizeProtocol = ViewComponentSize(size: .zero, type: .absolute)
}

public typealias ListSelectionClosure = (_: IndexPath) -> ()

open class ListSection {
    public weak var dataSource: ListDataSource?
    
    public var title: String = ""
    
    public var index: Int = 0
    
    public var edgeInsets: UIEdgeInsets?
    public var interitemSpacing: CGFloat = 0

    public var cellIdentifiers: [String]
    public var viewIdentifiers: [String]
    public var viewModels: [Any]
    public var sizes: [ViewComponentSizeProtocol]
    
    public var isWrapper: Bool {
        get {
            return !viewIdentifiers.isEmpty
        }
    }
    
    public var headerIdentifier: String?
    public var headerViewModel: Any?
    public var headerSize: ViewComponentSizeProtocol?
    
    public var footerIdentifier: String?
    public var footerViewModel: Any?
    public var footerSize: ViewComponentSizeProtocol?
    
    public var onSelect: ListSelectionClosure?
    
    public var viewModel: Any {
        get {
            return viewModels[0]
        }
        set(viewModel) {
            self.viewModels = [viewModel]
        }
    }
    
    public var size: ViewComponentSizeProtocol {
        get {
            return sizes[0]
        }
        set(size) {
            self.sizes = [size]
        }
    }
    
    public var actions: Any?
    public var headerActions: Any?
    public var footerActions: Any?
    
    var cellActionCallbacks: [UserActionCallbackPair] = []
    var headerActionCallbacks: [UserActionCallbackPair] = []
    var footerActionCallbacks: [UserActionCallbackPair] = []
    
    public let isMultiLayer: Bool
    
    public var isPagingEnabled: Bool = false {
        didSet {
            dataSource?.isPagingEnabledDidChange(to: isPagingEnabled)
        }
    }
    public var hasNextPage: Bool = false
    public var getNextPage: (() -> ())?
    
    public static func empty<T: ListSection>() -> T {
        return T(sizes: [ViewComponentSize.zero])
    }
    
    public required init(title: String = "",
         cellIdentifiers: [String] = [],
         viewIdentifiers: [String] = [],
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSizeProtocol] = [ViewComponentSize.zero],
         headerIdentifier: String? = nil,
         headerSize: ViewComponentSizeProtocol? = nil,
         headerViewModel: Any? = nil,
         footerIdentifier: String? = nil,
         footerSize: ViewComponentSizeProtocol? = nil,
         footerViewModel: Any? = nil,
         isMultiLayer: Bool = false,
         isPagingEnabled: Bool = false,
         onSelect: ListSelectionClosure? = nil) {
        self.title = title
        
        self.cellIdentifiers = cellIdentifiers
        self.viewIdentifiers = viewIdentifiers
        self.viewModels = viewModels
        self.actions = actions
        self.sizes = sizes
        
        self.headerIdentifier = headerIdentifier
        self.headerSize = headerSize
        self.headerViewModel = headerViewModel
        
        self.footerIdentifier = footerIdentifier
        self.footerSize = footerSize
        self.footerViewModel = footerViewModel
        
        self.isMultiLayer = isMultiLayer
        self.isPagingEnabled = isPagingEnabled
        self.onSelect = onSelect
    }
    
    public convenience init(title: String = "",
         viewIdentifier: String,
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSizeProtocol],
         headerIdentifier: String? = nil,
         headerSize: ViewComponentSizeProtocol? = nil,
         headerViewModel: Any? = nil,
         footerIdentifier: String? = nil,
         footerSize: ViewComponentSizeProtocol? = nil,
         footerViewModel: Any? = nil,
         isMultiLayer: Bool = false,
         onSelect: ListSelectionClosure? = nil){
        self.init(title: title, viewIdentifiers: [viewIdentifier], viewModels: viewModels, actions: actions, sizes: sizes, headerIdentifier: headerIdentifier, headerSize: headerSize, headerViewModel: headerViewModel, footerIdentifier: footerIdentifier, footerSize: footerSize, footerViewModel: footerViewModel, isMultiLayer: isMultiLayer, onSelect: onSelect)
    }
    
    public convenience init(title: String = "",
                     cellIdentifier: String,
                     viewModels: [Any] = [],
                     size: ViewComponentSizeProtocol,
                     headerIdentifier: String? = nil,
                     headerSize: ViewComponentSizeProtocol? = nil,
                     headerViewModel: Any? = nil,
                     footerIdentifier: String? = nil,
                     footerSize: ViewComponentSizeProtocol? = nil,
                     footerViewModel: Any? = nil,
                     isMultiLayer: Bool = false,
                     onSelect: ListSelectionClosure? = nil){
        self.init(title: title, cellIdentifiers: [cellIdentifier], viewModels: viewModels, sizes: [size], headerIdentifier: headerIdentifier, headerSize: headerSize, headerViewModel: headerViewModel, footerIdentifier: footerIdentifier, footerSize: footerSize, footerViewModel: footerViewModel, isMultiLayer: isMultiLayer, onSelect: onSelect)
    }

    
    public convenience init(title: String = "",
         cellIdentifier: String,
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSizeProtocol],
         headerIdentifier: String? = nil,
         headerSize: ViewComponentSizeProtocol? = nil,
         headerViewModel: Any? = nil,
         footerIdentifier: String? = nil,
         footerSize: ViewComponentSizeProtocol? = nil,
         footerViewModel: Any? = nil,
         isMultiLayer: Bool = false,
         onSelect: ListSelectionClosure? = nil){
        self.init(title: title, cellIdentifiers: [cellIdentifier], viewModels: viewModels, actions: actions, sizes: sizes, headerIdentifier: headerIdentifier, headerSize: headerSize, headerViewModel: headerViewModel, footerIdentifier: footerIdentifier, footerSize: footerSize, footerViewModel: footerViewModel, isMultiLayer: isMultiLayer, onSelect: onSelect)
    }
    
    public func update(viewModel: Any, at index: Int = 0) {
        viewModels[index] = viewModel
    }
    
    public func register(action: UserAction, in componentType: ListViewComponentType, callback: @escaping UserActionCallback) {
        let actionCallbackPair = (action, callback)
        
        switch componentType {
        case .cell:
            cellActionCallbacks.append(actionCallbackPair)
        case .header:
            headerActionCallbacks.append(actionCallbackPair)
        case .footer:
            footerActionCallbacks.append(actionCallbackPair)
        }
    }
    
    public func update<T: Hashable>(viewModels: [T], hasNextPage: Bool) {
        guard let oldViewModels = self.viewModels as? [T] else { return }
        
        self.hasNextPage = hasNextPage
        
        let oldDataSet = Set(oldViewModels)
        let newDataSet = Set(viewModels)
        
        let oldDataCount = oldViewModels.count
        
        var newViewModels = oldViewModels
        
        if !oldDataSet.isEmpty && oldDataSet.isSubset(of: newDataSet) && newDataSet.count != oldDataSet.count  {
            
            let newIndexPaths = viewModels.enumerated().filter({
                return $0.offset >= oldDataCount
            }).map { (enumeration: (offset: Int, element: T)) -> IndexPath in
                newViewModels.append(enumeration.element)
                
                return IndexPath(item: enumeration.offset, section: index)
            }
            self.viewModels = newViewModels
            dataSource?.didAddItems(at: newIndexPaths)
        } else {
            self.viewModels = viewModels
            dataSource?.didUpdateSection(at: index)
        }

        dataSource?.stopPaginationAnimation()
    }
    
    func identifier(forCellAt index: Int) -> String {
        if isWrapper {
            return WrapperCollectionCell.Identifier
        }
        return cellIdentifiers.count == 1 ? cellIdentifiers[0] : cellIdentifiers[index]
    }
    
    func viewIdentifier(forCellAt index: Int) -> String {
        return viewIdentifiers.count == 1 ? viewIdentifiers[0] : viewIdentifiers[index]
    }
    
    func size(forCellAt index: Int) -> ViewComponentSizeProtocol {
        return sizes.count == 1 ? sizes[0] : sizes[index]
    }
}

protocol BaseListView {
    var contentInset: UIEdgeInsets { get set }
    var contentOffset: CGPoint { get set }
    
    func reloadData()
    func reloadData(animated: Bool)
    func reloadData(at indexPaths: [IndexPath])
    func reload(sections: [Int])
    func insertItems(at indexPaths: [IndexPath])
    
    func registerHeader(withIdentifier identifier: String)
    func registerFooter(withIdentifier identifier: String)
    func registerCell(withIdentifier identifier: String)
    
    func registerCell(withClass cellClass: AnyClass, identifier: String)
    func registerHeader(withClass cellClass: AnyClass, identifier: String)
    func registerFooter(withClass cellClass: AnyClass, identifier: String)
    
    func makeReusableCell(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent?
    func makeReusableHeader(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent?
    func makeReusableFooter(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent?
}

extension UITableView: BaseListView {
    func insertItems(at indexPaths: [IndexPath]) {
        insertRows(at: indexPaths, with: .automatic)
    }

    func reloadData(animated: Bool) {
        reloadData()
    }
    
    func reload(sections: [Int]) {
        let sectionIndexSet = IndexSet(sections)
        reloadSections(sectionIndexSet, with: .automatic)
    }
    func reloadData(at indexPaths: [IndexPath]) {
        reloadRows(at: indexPaths, with: .automatic)
    }
    func registerHeader(withIdentifier identifier: String) {
        registerSupplementaryView(withIdentifier: identifier)
    }
    
    func registerFooter(withIdentifier identifier: String) {
        registerSupplementaryView(withIdentifier: identifier)
    }
    
    func registerCell(withIdentifier identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    func registerCell(withClass cellClass: AnyClass, identifier: String) {
        register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func registerHeader(withClass cellClass: AnyClass, identifier: String) {
        registerSupplementaryView(wtih: cellClass, identifier: identifier)
    }
    
    func registerFooter(withClass cellClass: AnyClass, identifier: String) {
        registerSupplementaryView(wtih: cellClass, identifier: identifier)
    }
    
    func makeReusableCell(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent? {
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ListViewComponent
    }
    
    func makeReusableHeader(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent? {
        return dequeueReusableHeaderFooterView(withIdentifier: identifier) as? ListViewComponent
    }
    
    func makeReusableFooter(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent? {
        return dequeueReusableHeaderFooterView(withIdentifier: identifier) as? ListViewComponent
    }
    
    private func registerSupplementaryView(withIdentifier identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    private func registerSupplementaryView(wtih viewClass: AnyClass, identifier: String) {
        registerSupplementaryView(wtih: viewClass, identifier: identifier)
    }
}
extension UICollectionView: BaseListView {
    func reloadData(animated: Bool) {
        guard let newSectionCount = dataSource?.numberOfSections?(in: self), animated else { return reloadData() }
        let oldSectionCount = numberOfSections
        
        performBatchUpdates({ [weak self] in
            self?.deleteSections(IndexSet(0..<oldSectionCount))
            self?.insertSections(IndexSet(0..<newSectionCount))
            }, completion: nil)
    }
    
    func reload(sections: [Int]) {
        let sectionIndexSet = IndexSet(sections)
        reloadSections(sectionIndexSet)
    }
    func reloadData(at indexPaths: [IndexPath]) {
        reloadItems(at: indexPaths)
    }
    func registerHeader(withIdentifier identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib,
                 forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                 withReuseIdentifier: identifier)
    }
    
    func registerFooter(withIdentifier identifier: String) {
         let nib = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib,
                 forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                 withReuseIdentifier: identifier)
    }
    
    func registerCell(withIdentifier identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func registerCell(withClass cellClass: AnyClass, identifier: String) {
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    func registerHeader(withClass cellClass: AnyClass, identifier: String) {
        register(cellClass, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    func registerFooter(withClass cellClass: AnyClass, identifier: String) {
        register(cellClass, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: identifier)
    }
    
    func makeReusableCell(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent? {
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ListViewComponent
    }
    
    func makeReusableHeader(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent? {
        return dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: identifier, for: indexPath) as? ListViewComponent
    }
    
    func makeReusableFooter(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent? {
        return dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: identifier, for: indexPath) as? ListViewComponent
    }
}

public class ListDataSource: NSObject {
    var listView: BaseListView!
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
    
    var pagingSection: ListSection? {
        return sections.last
    }
    
    var loadMoreView: LoadMoreView?
    
    var onItemShown: ((IndexPath) -> ())?
    
    init(sections: [ListSection], listView: BaseListView?) {
        self.sections = sections
        self.listView = listView
    }
    
    init(cellIdentifier: String,
         listView: BaseListView? = nil,
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSizeProtocol] = [],
         headerIdentifier: String? = nil,
         footerIdentifier: String? = nil,
         onSelect: ListSelectionClosure? = nil) {
        let section = ListSection(cellIdentifier: cellIdentifier,
                                  viewModels: viewModels,
                                  actions: actions,
                                  sizes: sizes,
                                  headerIdentifier: headerIdentifier,
                                  headerSize: ViewComponentSize.zero,
                                  headerViewModel: nil,
                                  footerIdentifier: footerIdentifier,
                                  footerSize: ViewComponentSize.zero,
                                  footerViewModel: nil,
                                  onSelect: onSelect)
        
        self.sections = [section]
        self.listView = listView
        
        super.init()
        
        section.index = 0
        section.dataSource = self
    }
    
    init(viewIdentifier: String,
         listView: BaseListView? = nil,
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSizeProtocol] = [],
         headerIdentifier: String? = nil,
         footerIdentifier: String? = nil,
         onSelect: ListSelectionClosure? = nil) {
        let section = ListSection(viewIdentifier: viewIdentifier,
                                  viewModels: viewModels,
                                  actions: actions,
                                  sizes: sizes,
                                  headerIdentifier: headerIdentifier,
                                  headerSize: ViewComponentSize.zero,
                                  headerViewModel: nil,
                                  footerIdentifier: footerIdentifier,
                                  footerSize: ViewComponentSize.zero,
                                  footerViewModel: nil,
                                  onSelect: onSelect)
        
        self.sections = [section]
        self.listView = listView
        
        super.init()
        
        section.index = 0
        section.dataSource = self
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
    
    func makeCell(at indexPath: IndexPath) -> ListViewComponent? {
        let section = sections[indexPath.section]
        let viewModel = section.viewModels[indexPath.row]
        
        let cellIdentifier = section.identifier(forCellAt: indexPath.row)
        
        if cellIdentifier != WrapperCollectionCell.Identifier,
            UINib.doesExist(withName: cellIdentifier) {
            
            listView.registerCell(withIdentifier: cellIdentifier)
        }
        
        guard let cell = listView.makeReusableCell(withIdentifier: cellIdentifier, at: indexPath) else { return nil }
        
        if let wrapperCell = cell as? WrapperCollectionCell,
            let customView = makeView(at: indexPath) {
            wrapperCell.set(customView: customView)
            wrapperCell.tag = indexPath.row
        }
        
        let onSelect = section.isMultiLayer ? section.onSelect : nil
        cell.update(withViewModel: viewModel, onSelect: onSelect)
        
        section.cellActionCallbacks.forEach { (action, callback) in
            cell.register(action: action, callback: callback)
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
            pagingSection.hasNextPage {
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
        
        if showSectionSeparators {
            return ViewComponentSize(size: CGSize(width: 1, height: 1), widthType: .relative, heightType: .absolute, edgeInsets: separatorInsets)
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

extension UINib {
    static func doesExist(withName name: String, in bundle: Bundle = .main) -> Bool {
        let path = bundle.path(forResource: name, ofType: "nib")
        return path != nil
    }
}
