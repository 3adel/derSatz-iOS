//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

public class TableViewDataSource: ListDataSource {
    override var listView: ListView! {
        didSet {
            setupTableView()
        }
    }
    
    public init(cellIdentifier: String,
                     tableView: UITableView? = nil,
                     viewModels: [Any] = [],
                     sizes: [ViewComponentSize] = [],
                     headerIdentifier: String? = nil,
                     footerIdentifier: String? = nil,
                     onSelect: ListSelectionClosure? = nil) {
        super.init(cellIdentifier: cellIdentifier,
                  listView: tableView,
                  viewModels: viewModels,
                  sizes: sizes,
                  headerIdentifier: headerIdentifier,
                  footerIdentifier: footerIdentifier,
                  onSelect: onSelect)
        
        setupTableView()
    }
    
    public convenience init(cellIdentifier: String,
                     tableView: UITableView? = nil,
                     viewModels: [Any] = [],
                     size: ViewComponentSize = .zero,
                     headerIdentifier: String? = nil,
                     footerIdentifier: String? = nil,
                     onSelect: ListSelectionClosure? = nil) {
        self.init(cellIdentifier: cellIdentifier,
                  tableView: tableView,
                  viewModels: viewModels,
                  sizes: [size],
                  headerIdentifier: headerIdentifier,
                  footerIdentifier: footerIdentifier,
                  onSelect: onSelect)
    }
    
    func setupTableView() {
        guard let tableView = listView as? UITableView else { return }
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension TableViewDataSource: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return makeCell(at: indexPath) as? UITableViewCell ?? UITableViewCell()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = getSize(forCellAt: indexPath)
        let height = size.heightType == .relative ? size.size.height * tableView.frame.height : size.size.height
        
        return height - tableView.contentInset.top - tableView.contentInset.bottom
    }
    
    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let size = getSize(forCellAt: indexPath)
        return size.indentLevel
    }
}

extension TableViewDataSource: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectItem(at: indexPath)
    }
}
