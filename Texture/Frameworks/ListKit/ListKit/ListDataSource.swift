//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

public protocol ListViewComponent {
    func update(withViewModel viewModel: Any)
    func update(withViewModel viewModel: Any, onSelect: ListSelectionClosure?)
    func update(withViewModel viewModel: Any, actions: Any?, onSelect: ListSelectionClosure?)
}

public extension ListViewComponent {
    //Default implementation
    func update(withViewModel viewModel: Any, onSelect: ListSelectionClosure?) {
        update(withViewModel: viewModel)
    }
    func update(withViewModel viewModel: Any, actions: Any?, onSelect: ListSelectionClosure?) {
        update(withViewModel: viewModel, onSelect: onSelect)
    }
    func update(withViewModel viewModel: Any) {}
}

public enum ViewComponentSizeType {
    case absolute, relative
}

public struct ViewComponentSize {
    let size: CGSize
    let edgeInsets: UIEdgeInsets
    let indentLevel: Int
    let widthType: ViewComponentSizeType
    let heightType: ViewComponentSizeType
    
    public init(size: CGSize, widthType: ViewComponentSizeType, heightType: ViewComponentSizeType, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.size = size
        self.widthType = widthType
        self.heightType = heightType
        self.edgeInsets = edgeInsets
        self.indentLevel = indentLevel
    }
    
    public init(size: CGSize, type: ViewComponentSizeType = .absolute, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.init(size: size, widthType: type, heightType: type, edgeInsets: edgeInsets)
    }
    
    public init(height: CGFloat, type: ViewComponentSizeType = .absolute, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.init(size: CGSize(width: 1, height: height),
                  widthType: .relative,
                  heightType: type,
                  edgeInsets: edgeInsets,
                  indentLevel: indentLevel)
    }
    
    func calculateActualSize(in frame: CGRect? = nil) -> CGSize {
        if widthType == .absolute && heightType == .absolute {
            return size
        }
        guard let frame = frame else { return .zero }
        
        let width = widthType == .relative ? frame.width * size.width : size.width
        let height = heightType == .relative ? frame.height * size.height : size.height
        return CGSize(width: width, height: height)
    }
    
    static let zero: ViewComponentSize = ViewComponentSize(size: .zero, type: .absolute)
}

public typealias ListSelectionClosure = (_: IndexPath) -> ()

public class ListSection {
    public var title: String = ""
    
    public var edgeInsets: UIEdgeInsets?
    public var interitemSpacing: CGFloat = 0

    public var cellIdentifiers: [String]
    public var viewIdentifiers: [String]
    public var viewModels: [Any]
    public var sizes: [ViewComponentSize]
    
    var isWrapper: Bool {
        get {
            return !viewIdentifiers.isEmpty
        }
    }
    
    var headerIdentifier: String?
    var headerViewModel: Any?
    var headerSize: ViewComponentSize?
    
    var footerIdentifier: String?
    var footerViewModel: Any?
    var footerSize: ViewComponentSize?
    
    var onSelect: ListSelectionClosure?
    
    public var viewModel: Any {
        get {
            return viewModels[0]
        }
    }
    
    public var actions: Any?
    
    let isMultiLayer: Bool
    
    public init(title: String = "",
         cellIdentifiers: [String] = [],
         viewIdentifiers: [String] = [],
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSize],
         headerIdentifier: String? = nil,
         headerSize: ViewComponentSize? = nil,
         headerViewModel: Any? = nil,
         footerIdentifier: String? = nil,
         footerSize: ViewComponentSize? = nil,
         footerViewModel: Any? = nil,
         isMultiLayer: Bool = false,
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
        self.onSelect = onSelect
    }
    
    public convenience init(title: String = "",
         viewIdentifier: String,
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSize],
         headerIdentifier: String? = nil,
         headerSize: ViewComponentSize? = nil,
         headerViewModel: Any? = nil,
         footerIdentifier: String? = nil,
         footerSize: ViewComponentSize? = nil,
         footerViewModel: Any? = nil,
         isMultiLayer: Bool = false,
         onSelect: ListSelectionClosure? = nil){
        self.init(title: title, viewIdentifiers: [viewIdentifier], viewModels: viewModels, actions: actions, sizes: sizes, headerIdentifier: headerIdentifier, headerSize: headerSize, headerViewModel: headerViewModel, footerIdentifier: footerIdentifier, footerSize: footerSize, footerViewModel: footerViewModel, isMultiLayer: isMultiLayer, onSelect: onSelect)
    }
    
    public convenience init(title: String = "",
                     cellIdentifier: String,
                     viewModels: [Any] = [],
                     size: ViewComponentSize,
                     headerIdentifier: String? = nil,
                     headerSize: ViewComponentSize? = nil,
                     headerViewModel: Any? = nil,
                     footerIdentifier: String? = nil,
                     footerSize: ViewComponentSize? = nil,
                     footerViewModel: Any? = nil,
                     isMultiLayer: Bool = false,
                     onSelect: ListSelectionClosure? = nil){
        self.init(title: title, cellIdentifiers: [cellIdentifier], viewModels: viewModels, sizes: [size], headerIdentifier: headerIdentifier, headerSize: headerSize, headerViewModel: headerViewModel, footerIdentifier: footerIdentifier, footerSize: footerSize, footerViewModel: footerViewModel, isMultiLayer: isMultiLayer, onSelect: onSelect)
    }

    
    public convenience init(title: String = "",
         cellIdentifier: String,
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSize],
         headerIdentifier: String? = nil,
         headerSize: ViewComponentSize? = nil,
         headerViewModel: Any? = nil,
         footerIdentifier: String? = nil,
         footerSize: ViewComponentSize? = nil,
         footerViewModel: Any? = nil,
         isMultiLayer: Bool = false,
         onSelect: ListSelectionClosure? = nil){
        self.init(title: title, cellIdentifiers: [cellIdentifier], viewModels: viewModels, actions: actions, sizes: sizes, headerIdentifier: headerIdentifier, headerSize: headerSize, headerViewModel: headerViewModel, footerIdentifier: footerIdentifier, footerSize: footerSize, footerViewModel: footerViewModel, isMultiLayer: isMultiLayer, onSelect: onSelect)
    }
    
    public func update(viewModel: Any, at index: Int = 0) {
        viewModels[index] = viewModel
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
    
    func size(forCellAt index: Int) -> ViewComponentSize {
        return sizes.count == 1 ? sizes[0] : sizes[index]
    }
}

protocol ListView {
    func reloadData()
    func reloadData(animated: Bool)
    func reloadData(at indexPaths: [IndexPath])
    func reload(sections: [Int])
    func registerHeader(withIdentifier identifier: String)
    func registerCell(withIdentifier identifier: String)
    func makeReusableCell(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent?
    func makeReusableHeader(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent?
    func makeReusableFooter(withIdentifier identifier: String, at indexPath: IndexPath) -> ListViewComponent?
}

extension UITableView: ListView {
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
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    func registerCell(withIdentifier identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib, forCellReuseIdentifier: identifier)
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
}
extension UICollectionView: ListView {
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
    func registerCell(withIdentifier identifier: String) {
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib, forCellWithReuseIdentifier: identifier)
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
    var listView: ListView!
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
    
    init(sections: [ListSection], listView: ListView?) {
        self.sections = sections
        self.listView = listView
    }
    
    init(cellIdentifier: String,
         listView: ListView? = nil,
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSize] = [],
         headerIdentifier: String? = nil,
         footerIdentifier: String? = nil,
         onSelect: ListSelectionClosure? = nil) {
        let section = ListSection(cellIdentifier: cellIdentifier,
                                  viewModels: viewModels,
                                  actions: actions,
                                  sizes: sizes,
                                  headerIdentifier: headerIdentifier,
                                  headerSize: .zero,
                                  headerViewModel: nil,
                                  footerIdentifier: footerIdentifier,
                                  footerSize: .zero,
                                  footerViewModel: nil,
                                  onSelect: onSelect)
        self.sections = [section]
        self.listView = listView
    }
    
    init(viewIdentifier: String,
         listView: ListView? = nil,
         viewModels: [Any] = [],
         actions: Any? = nil,
         sizes: [ViewComponentSize] = [],
         headerIdentifier: String? = nil,
         footerIdentifier: String? = nil,
         onSelect: ListSelectionClosure? = nil) {
        let section = ListSection(viewIdentifier: viewIdentifier,
                                  viewModels: viewModels,
                                  actions: actions,
                                  sizes: sizes,
                                  headerIdentifier: headerIdentifier,
                                  headerSize: .zero,
                                  headerViewModel: nil,
                                  footerIdentifier: footerIdentifier,
                                  footerSize: .zero,
                                  footerViewModel: nil,
                                  onSelect: onSelect)
        self.sections = [section]
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
        self.sections = sections
        reloadList(animated: animated)
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
        cell.update(withViewModel: viewModel, actions: section.actions, onSelect: onSelect)
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
        return header
    }
    
    func makeFooter(at indexPath: IndexPath) -> ListViewComponent? {
        if showSectionSeparators {
            return listView.makeReusableFooter(withIdentifier: SeparatorFooterView.Identifier, at: indexPath)
        }
        
        let section = sections[indexPath.section]
        
        guard let footerIdentifier = section.footerIdentifier,
            let footerViewModel = section.footerViewModel,
            let footer = listView.makeReusableFooter(withIdentifier: footerIdentifier, at: indexPath) else { return nil }
        
        footer.update(withViewModel: footerViewModel)
        return footer
    }
    
    func numberOfItems(in section: Int) -> Int {
        return sections[section].viewModels.count
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func getSize(forCellAt indexPath: IndexPath) -> ViewComponentSize {
        return sections[indexPath.section].size(forCellAt: indexPath.row)
    }
    
    func getSize(forHeaderInSection sectionIndex: Int) -> ViewComponentSize {
        return sections[sectionIndex].headerSize ?? .zero
    }
    
    func getSize(forFooterInSection sectionIndex: Int) -> ViewComponentSize {
        if showSectionSeparators {
            return ViewComponentSize(size: CGSize(width: 1, height: 1), widthType: .relative, heightType: .absolute, edgeInsets: separatorInsets)
        } else {
            return sections[sectionIndex].footerSize ?? .zero
        }
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        let section = sections[indexPath.section]
        section.onSelect?(indexPath)
    }
}

extension UINib {
    static func doesExist(withName name: String, in bundle: Bundle = .main) -> Bool {
        let path = bundle.path(forResource: name, ofType: "nib")
        return path != nil
    }
}
