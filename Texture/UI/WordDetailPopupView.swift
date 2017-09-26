//
//  WordDetailPopupView.swift
//  Texture
//
//  Created by Halil Gursoy on 21.09.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit

struct WordDetailPopupViewModel {
    let word: String
    let translation: String
    let originalLanguageImageName: String
    let translatedLanguageImageName: String
    let lemma: String
    let lexicalClass: String
    let backgroundColor: UIColor
}

class WordDetailPopupView: UIView {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var triangleImageView: UIImageView!
    
    @IBOutlet private var wordLabel: UILabel!
    @IBOutlet private var translationLabel: UILabel!
    @IBOutlet private var originalLanguageImageView: UIImageView!
    @IBOutlet private var translatedLanguageImageView: UIImageView!
    @IBOutlet private var lemmaLabel: UILabel!
    @IBOutlet private var lexicalClassLabel: UILabel!
    
    @IBOutlet private var triangleXConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func update(with viewModel: WordDetailPopupViewModel) {
        wordLabel.text = viewModel.word
        translationLabel.text = viewModel.translation
        originalLanguageImageView.image = UIImage(named: viewModel.originalLanguageImageName)
        translatedLanguageImageView.image = UIImage(named: viewModel.translatedLanguageImageName)
        lemmaLabel.text = " - \(viewModel.lemma) - "
        lexicalClassLabel.text = viewModel.lexicalClass
        
        containerView.backgroundColor = viewModel.backgroundColor
        let triangleImage = UIImage(named: "popupTriangle")?.tint(with: viewModel.backgroundColor)
        triangleImageView.image = triangleImage
    }
    
    func moveTriangle(to x: CGFloat) {
        triangleXConstraint.constant = x
        setNeedsLayout()
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 6
    }
}
