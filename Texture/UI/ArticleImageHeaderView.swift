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
//        let canOpenURL: Bool
//
//        #if TARGET_IS_APP
//            if let imageURL = viewModel.imageURL {
//                canOpenURL = UIApplication.shared.canOpenURL(imageURL)
//            } else {
//                canOpenURL = false
//            }
//        #else
//        canOpenURL = false
//        #endif
        
        if let imageURL = viewModel.imageURL {
//            canOpenURL {
            imageHeader.setHeightConstraint(to: 215)
            imageHeader.setImage(withUrl: imageURL)
        } else {
            imageHeader.setHeightConstraint(to: 0)
        }
        titleLabel.text = viewModel.title
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .left
    }
}
