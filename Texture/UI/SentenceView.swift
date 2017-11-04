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
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var originalTextView: UITextView!
    @IBOutlet weak var translatedTextView: UITextView!
    
    @IBOutlet weak var originalTextViewConstraint: NSLayoutConstraint!
    
    var onDidTapWord: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    var viewModel: SentenceViewModel?
    
    var detailPopup: WordDetailPopupView?
    
    static let originalTextViewFont = UIFont.systemFont(ofSize: 19)
    static let translatedTextViewFont = UIFont.systemFont(ofSize: 17)
    
    func update(with viewModel: SentenceViewModel) {
        self.viewModel = viewModel
        originalTextView.attributedText = NSAttributedString(string: viewModel.sentence, attributes: [.font : SentenceView.originalTextViewFont])
        translatedTextView.text = viewModel.translation
        
        originalTextViewConstraint.constant = viewModel.sentence.height(withConstrainedWidth: originalTextView.frame.width, font: originalTextView.font!)

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
        
        originalTextView.font = SentenceView.originalTextViewFont
        translatedTextView.font = SentenceView.translatedTextViewFont
        translatedTextView.backgroundColor = UIColor(red: 92/255, green: 146/255, blue: 253/255, alpha: 1)
        translatedTextView.textColor = .white
        translatedTextView.layer.cornerRadius = 6
        originalTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTextView(_:))))
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

extension SentenceView {
    static func calculateHeight(for viewModel: SentenceViewModel, inWidth width: CGFloat) -> CGFloat {
        let textViewWidth = width - 20
        
        return viewModel.sentence.height(withConstrainedWidth: textViewWidth, font: originalTextViewFont) + viewModel.translation.height(withConstrainedWidth: textViewWidth, font: translatedTextViewFont) + 10
    }
}

extension SentenceView: ListViewComponent {
    func update(withViewModel viewModel: Any) {
        guard let viewModel = viewModel as? SentenceViewModel else { return }
        update(with: viewModel)
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
