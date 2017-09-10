//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import Foundation

protocol ListViewProtocol: class {
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

extension UITableView: ListViewProtocol {
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
extension UICollectionView: ListViewProtocol {
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

public extension UICollectionView {
    func reloadData(animated: Bool) {
        guard let newSectionCount = dataSource?.numberOfSections?(in: self), animated else { return reloadData() }
        let oldSectionCount = numberOfSections
        
        performBatchUpdates({ [weak self] in
            self?.deleteSections(IndexSet(0..<oldSectionCount))
            self?.insertSections(IndexSet(0..<newSectionCount))
            }, completion: nil)
    }
}
