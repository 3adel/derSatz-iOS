//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

public class TableViewDataSource: ListDataSource {
    override var listView: ListViewProtocol! {
        didSet {
            setupTableView()
        }
    }
    
    public required init(tableView: UITableView) {
        super.init(sections: [], listView: tableView)
        setupTableView()
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
        var actualSize = size.calculateActualSize(in: tableView.frame)
        
        actualSize.height -= tableView.contentInset.top + tableView.contentInset.bottom
        
        return actualSize.height
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
