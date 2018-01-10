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
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var translationStackView: UIStackView!
    @IBOutlet private var audioButton: AnimatedButton!
    
    @IBOutlet private var triangleXConstraint: NSLayoutConstraint!
    @IBOutlet private var triangleTopConstraints: [NSLayoutConstraint]!
    @IBOutlet private var triangleBottomConstraints: [NSLayoutConstraint]!
    
    private let speaker = TextSpeaker(language: .german)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func update(with viewModel: WordDetailPopupViewModel) {
        wordLabel.text = viewModel.word
        
        if !viewModel.translation.isEmpty {
            translationLabel.text = viewModel.translation
            activityIndicator.removeFromSuperview()
            activityIndicator.stopAnimating()
        } else {
            translationLabel.text = ""
            translationStackView.insertArrangedSubview(activityIndicator, at: 1)
            activityIndicator.startAnimating()
        }
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
    
    @IBAction func didTapAudioButton(_ sender: UIControl) {
        guard !speaker.isPlaying else { return }
        speaker.play(wordLabel.text!)
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 6
        audioButton.tintColor = .white
        
        let speakerImage = UIImage(named: "speaker")?.withRenderingMode(.alwaysTemplate)
        audioButton.setBackgroundImage(speakerImage, for: .normal)
        audioButton.images = [#imageLiteral(resourceName: "speaker_1"), #imageLiteral(resourceName: "speaker"), #imageLiteral(resourceName: "speaker_3")].map { $0.withRenderingMode(.alwaysTemplate) }
        
        [wordLabel, translationLabel, lemmaLabel, lexicalClassLabel].forEach { $0?.textColor = .white }
    }
}

extension WordDetailPopupView: TextSpeakerDelegate {
    func speakerDidStartPlayback(for text: String) {
        audioButton.startAnimating()
    }
    
    func speakerDidFinishPlayback(for text: String) {
        audioButton.stopAnimating()
    }
}
