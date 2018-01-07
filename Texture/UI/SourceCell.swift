//
//  PlainTextCell.swift
//  Texture
//
//  Created by Halil Gursoy on 07.01.18.
//  Copyright © 2018 Texture. All rights reserved.
//

import UIKit

typealias SourceViewModel = SourceCell.ViewModel

class SourceCell: UICollectionViewCell {
    struct ViewModel {
        let urlString: String
    }
    
    @IBOutlet private var textLabel: UILabel!
    
    
    func update(with viewModel: ViewModel) {
        textLabel.text = "Source: \(viewModel.urlString)"
    }
}
