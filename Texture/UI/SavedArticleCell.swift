//
//  SavedArticleCell.swift
//  Texture
//
//  Created by Halil Gursoy on 10.12.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import ListKit
import MapleBacon

class SavedArticleCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var sourceLabel: UILabel!
    @IBOutlet private var articleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        articleImageView.widthConstraintValue = 60
        sourceLabel.heightConstraintValue = 13
    }
    
    func setupUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 17)
    }
    
    func update(with viewModel: SavedArticleViewModel) {
        titleLabel.text = viewModel.title
        
        if let source = viewModel.source {
            sourceLabel.text = "Source: \(source)"
        } else {
            sourceLabel.heightConstraintValue = 0
        }
        
        if let imageURL = viewModel.imageURL {
            articleImageView.setImage(withUrl: imageURL)
        } else {
            articleImageView.widthConstraintValue = 0
        }
    }
}

extension SavedArticleCell: ListViewComponent {
    func update(withViewModel viewModel: Any) {
        guard let viewModel = viewModel as? SavedArticleViewModel else { return }
        update(with: viewModel)
    }
}
