//
//  ArticleImageHeader.swift
//  Texture
//
//  Created by Halil Gursoy on 04.11.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import MapleBacon

class ArticleImageHeaderView: UICollectionReusableView {
    @IBOutlet private var imageHeader: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func update(with viewModel: ArticleImageHeaderViewModel) {
        imageHeader.setImage(withUrl: viewModel.imageURL)
        titleLabel.text = viewModel.title
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
    }
}
