//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import Foundation

public typealias ListSelectionClosure = (_: IndexPath) -> ()

open class ListSection {
    public weak var dataSource: ListDataSource?
    
    public var title: String = ""
    
    public var index: Int = 0
    
    public var edgeInsets: UIEdgeInsets = .zero
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
    
    public var hasStickyHeader: Bool = false {
        didSet {
            if hasStickyHeader {
                stickyHeaderInfo = StickyHeaderInfo()
            } else {
                stickyHeaderInfo = nil
            }
        }
    }
    
    public var headerIdentifier: String?
    public var headerViewModel: Any?
    public var headerSize: ViewComponentSizeProtocol?
    
    public var footerIdentifier: String?
    public var footerViewModel: Any?
    public var footerSize: ViewComponentSizeProtocol?
    
    public var onSelect: ListSelectionClosure?
    
    public var layout: CollectionViewSectionLayout = CollectionViewSectionFlowLayout()
    
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
    
    var stickyHeaderInfo: StickyHeaderInfo?
    
    public let isMultiLayer: Bool
    
    public var isPagingEnabled: Bool = false {
        didSet {
            dataSource?.isPagingEnabledDidChange(to: isPagingEnabled)
        }
    }
    public var hasNextPage: Bool = false
    public var getNextPage: (() -> ())?
    
    public var numberOfItems: Int {
        return viewModels.count
    }
    
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
        dataSource?.reloadItems(at: [index], in: index)
    }
    
    public func cell(at row: Int) -> UIView? {
        return dataSource?.makeCell(at: IndexPath(item: row, section: index)) as? UIView
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
