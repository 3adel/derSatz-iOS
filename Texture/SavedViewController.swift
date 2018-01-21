//
//  SavedViewController.swift
//  Texture
//
//  Created by Halil Gursoy on 18.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import RVMP
import ListKit

class SavedViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noEntryLabel: UILabel!
    @IBOutlet private var noEntryImageView: UIImageView!
    
    var presenter: BasePresenter?
    
    var savedPresenter: SavedPresenterProtocol? {
        return presenter as? SavedPresenterProtocol
    }
    
    private let themeService = ThemeService()
    private var dataSource: TableViewDataSource?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationBar = navigationController?.navigationBar {
            themeService.setUpDefaultUI(for: navigationBar)
        }
        
        presenter?.getInitialData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = TableViewDataSource(tableView: tableView)
        dataSource?.onDeleteAction = { [weak self] indexPath, completionHandler in
            self?.savedPresenter?.didTapDeleteForArticle(at: indexPath.item) { success in
                completionHandler(success)
            }
        }
        setupUI()
    }
    
    private func setupUI() {
        hideBackButtonText()
        noEntryLabel.text = "No saved entries"
    }
}

extension SavedViewController: SavedViewProtocol {
    func render(with viewModel: [SavedArticleViewModel]) {
        let size = ViewComponentSize(height: 74)
        let section = ListSection(cellIdentifier: SavedArticleCell.Identifier, viewModels: viewModel, size: size) { [weak self] indexPath in
            self?.savedPresenter?.didTapOnArticle(at: indexPath.item)
        }
        dataSource?.update(sections: [section])
        
        updateNoEntryViews(shouldShow: viewModel.isEmpty)
    }
    
    func update(viewModels: [SavedArticleViewModel]) {
        dataSource?.update(viewModels: viewModels)
        
        updateNoEntryViews(shouldShow: viewModels.isEmpty)
    }
    
    private func updateNoEntryViews(shouldShow: Bool) {
         [noEntryLabel, noEntryImageView].forEach { $0.isHidden = !shouldShow}
    }
}
