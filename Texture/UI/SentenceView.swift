//
//  SentenceView.swift
//  Texture
//
//  Created by Halil Gursoy on 30.07.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import ListKit

//https://stackoverflow.com/questions/20694942/using-a-calayer-to-highlight-text-in-a-uitextview-which-spans-multiple-lines

enum SentenceAction: String, UserAction {
    case didTapWord
}

class SentenceView: UICollectionViewCell {
    @IBOutlet private var containerStackView: UIStackView!
    @IBOutlet private var originalTextView: UITextView!
    @IBOutlet private var originalTextBackgroundView: UIView!
    @IBOutlet private var translatedTextView: UITextView!
    @IBOutlet private var translatedTextBackgroundView: UIView!
    
    @IBOutlet private var originalSpeakerButton: AnimatedButton!
    @IBOutlet private var translatedSpeakerButton: AnimatedButton!
    
    @IBOutlet weak var originalTextViewConstraint: NSLayoutConstraint!
    
    var onDidTapWord: ((Int) -> Void)?
    
    private let speaker = TextSpeaker(language: .german)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        
        speaker.delegate = self
    }
    
    var viewModel: SentenceViewModel?
    
    var detailPopup: WordDetailPopupView?
    
    static let originalTextViewFontSize: CGFloat = 19
    static let translatedTextViewFontSize: CGFloat = 17
    
    static let textViewPadding: CGFloat = 70
    
    func update(with viewModel: SentenceViewModel, width: CGFloat) {
        self.viewModel = viewModel
        originalTextView.attributedText = NSAttributedString(string: viewModel.sentence, attributes: [.font : UIFont.systemFont(ofSize: SentenceView.originalTextViewFontSize, weight: viewModel.fontWeight)])
        translatedTextView.attributedText = NSAttributedString(string: viewModel.translation,
                                                               attributes: [
                                                                .font : UIFont.systemFont(ofSize: SentenceView.translatedTextViewFontSize, weight: viewModel.fontWeight),
                                                                .foregroundColor: UIColor.white])
        
        originalTextViewConstraint.constant = viewModel.sentence.height(withConstrainedWidth: width - SentenceView.textViewPadding, font: originalTextView.font!)
        setNeedsLayout()

        viewModel.wordInfos.forEach {
            guard $0.type != .other else { return }
            
            self.addHighlight(to: $0.range, with: $0.type.color)
        }
    }
    
    func frameForWord(at index: Int) -> CGRect? {
        guard let word = viewModel?.wordInfos[index],
            let range = UITextRange.from(range: word.range, in: originalTextView) else { return nil }
        
        let wordFrameInTextView = originalTextView.firstRect(for: range)
        return convert(wordFrameInTextView, from: originalTextView)
    }
    
    @IBAction private func didTapSpeaker(_ sender: UIControl) {
        speaker.stop()
        
        if sender === originalSpeakerButton {
            speaker.language = .german
            speaker.play(originalTextView.text)
        } else {
            speaker.language = .english
            speaker.play(translatedTextView.text)
        }
    }
    
    @objc func didTapTextView(_ sender: UITapGestureRecognizer) {
        let position = sender.location(in: originalTextView)
        let tapPosition = originalTextView.closestPosition(to: position)
        guard let textRange = originalTextView.tokenizer.rangeEnclosingPosition(tapPosition!, with: .word, inDirection: UITextLayoutDirection.right.rawValue)   else { return }
        
        let range = textRange.toRange(in: originalTextView)
        guard let index = indexOfWord(at: range) else { return }
        
        onDidTapWord?(index)
    }
    
    private func setupUI() {
        [originalTextView, translatedTextView].forEach {
            $0?.isEditable = false
            $0?.isScrollEnabled = false
        }
        
        originalTextView.font = UIFont.systemFont(ofSize: SentenceView.originalTextViewFontSize, weight: viewModel?.fontWeight ?? .regular)
        
        translatedTextView.font = UIFont.systemFont(ofSize: SentenceView.translatedTextViewFontSize, weight: viewModel?.fontWeight ?? .regular)
        
        translatedTextView.backgroundColor = .clear
        translatedTextBackgroundView.backgroundColor = UIColor(red: 92/255, green: 146/255, blue: 253/255, alpha: 1)
        translatedTextBackgroundView.layer.cornerRadius = 6
        originalTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTextView(_:))))
        
        translatedSpeakerButton.tintColor = .white
        originalSpeakerButton.tintColor = .black
        
        [originalSpeakerButton, translatedSpeakerButton].forEach {
            let speakerImage = UIImage(named: "speaker")?.withRenderingMode(.alwaysTemplate)
            $0?.setImage(speakerImage, for: .normal)
            
            $0?.images = [#imageLiteral(resourceName: "speaker_1"), #imageLiteral(resourceName: "speaker"), #imageLiteral(resourceName: "speaker_3")].map { $0.withRenderingMode(.alwaysTemplate) }
        }
    }
    
    
    private func addHighlight(to range: NSRange, with color: UIColor) {
        let attributedText = NSMutableAttributedString(attributedString: originalTextView.attributedText)
        
        attributedText.addAttributes([.foregroundColor : color], range: range)
        
        originalTextView.attributedText = attributedText
        return
    }
    
    private func indexOfWord(at range: NSRange) -> Int? {
        return viewModel?.wordInfos.enumerated().reduce(nil) { result, enumeration in
            return result != nil ? result : (enumeration.element.range == range ? enumeration.offset : nil)
        }   
    }
}

extension SentenceView: TextSpeakerDelegate {
    func speakerDidStartPlayback(for text: String) {
        let button = text == originalTextView.text ? originalSpeakerButton : translatedSpeakerButton
        button?.startAnimating()
    }
    
    func speakerDidFinishPlayback(for text: String) {
        let button = text == originalTextView.text ? originalSpeakerButton : translatedSpeakerButton
        button?.stopAnimating()
    }
}

extension SentenceView {
    static func calculateHeight(for viewModel: SentenceViewModel, inWidth width: CGFloat) -> CGFloat {
        let textViewWidth = width - textViewPadding
        
        return viewModel.sentence.height(withConstrainedWidth: textViewWidth, font: UIFont.systemFont(ofSize: originalTextViewFontSize, weight: viewModel.fontWeight)) + viewModel.translation.height(withConstrainedWidth: textViewWidth, font: UIFont.systemFont(ofSize: translatedTextViewFontSize, weight: viewModel.fontWeight)) + 10
    }
}

extension SentenceView: ListViewComponent {
    func update(withViewModel viewModel: Any) {
//        guard let viewModel = viewModel as? SentenceViewModel else { return }
//        update(with: viewModel)
    }
    
    func register(action: UserAction, callback: @escaping UserActionCallback) {
        guard let action = action as? SentenceAction else { return }
        
        switch action {
        case .didTapWord:
            onDidTapWord = { [weak self] index in
                guard let `self` = self else { return }
                let indexPath = IndexPath(item: index, section: self.tag)
                callback(nil, indexPath)
            }
        }
    }
}
