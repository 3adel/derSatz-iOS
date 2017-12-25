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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with viewModel: ArticleImageHeaderViewModel) {
        if let imageURL = viewModel.imageURL {
            imageHeader.setHeightConstraint(to: 215)
            imageHeader.setImage(withUrl: imageURL)
        } else {
            imageHeader.setHeightConstraint(to: 0)
        }
    }
}
