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

enum TrianglePosition {
    case up, down
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
    @IBOutlet private var triangleTopConstraints: [NSLayoutConstraint]!
    @IBOutlet private var triangleBottomConstraints: [NSLayoutConstraint]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func update(with viewModel: WordDetailPopupViewModel) {
        wordLabel.text = viewModel.word
        translationLabel.text = viewModel.translation
        originalLanguageImageView.image = UIImage(named: viewModel.originalLanguageImageName)
        translatedLanguageImageView.image = UIImage(named: viewModel.translatedLanguageImageName)
        
        let lemmaString = NSMutableAttributedString(string: "Lemma: \(viewModel.lemma)")
        lemmaString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: (lemmaString.string as NSString).range(of: "Lemma:"))
        lemmaLabel.attributedText = lemmaString
        
        let lexicalString = NSMutableAttributedString(string: "Parf of speech: \(viewModel.lexicalClass)")
        lexicalString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: (lexicalString.string as NSString).range(of: "Parf of speech:"))
        lexicalClassLabel.attributedText = lexicalString
        
        containerView.backgroundColor = viewModel.backgroundColor
        let triangleImage = UIImage(named: "popupTriangle")?.tint(with: viewModel.backgroundColor)
        triangleImageView.image = triangleImage
    }
    
    func moveTriangle(to x: CGFloat, position: TrianglePosition) {
        triangleXConstraint.constant = x
        
        
        let activateConstraints: [NSLayoutConstraint]
        let deactiveConstraints: [NSLayoutConstraint]
        let rotationAngle: CGFloat
        switch position {
        case .up:
            activateConstraints = triangleTopConstraints
            deactiveConstraints = triangleBottomConstraints
            rotationAngle = 0
        case .down:
            activateConstraints = triangleBottomConstraints
            deactiveConstraints = triangleTopConstraints
            rotationAngle = .pi
        }
        
        NSLayoutConstraint.activate(activateConstraints)
        NSLayoutConstraint.deactivate(deactiveConstraints)
        
        triangleImageView.transform = CGAffineTransform.identity.rotated(by: rotationAngle)
        setNeedsLayout()
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 6
        
        [wordLabel, translationLabel, lemmaLabel, lexicalClassLabel].forEach { $0?.textColor = .white }
    }
}
