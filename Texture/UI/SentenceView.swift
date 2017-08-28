//
//  SentenceView.swift
//  Texture
//
//  Created by Halil Gursoy on 30.07.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import ListKit

class SentenceView: UIView {
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var originalTextView: UITextView!
    @IBOutlet weak var translatedTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func update(with viewModel: SentenceViewModel) {
        originalTextView.text = viewModel.sentence
        translatedTextView.text = viewModel.translation
        
        let nounRanges = viewModel.wordInfos.filter { $0.type == .noun }.map { $0.range }
        let verbRanges = viewModel.wordInfos.filter { $0.type == .verb }.map { $0.range }
        let pronounRanges = viewModel.wordInfos.filter { $0.type == .pronoun }.map { $0.range }
        let adverbRanges = viewModel.wordInfos.filter { $0.type == .adverb }.map { $0.range }
        let adjectiveRanges = viewModel.wordInfos.filter { $0.type == .adjective }.map { $0.range }
        
        
        nounRanges.forEach { range in
            self.addHighlight(to: range, withColor: UIColor(red: 13/255, green: 113/255, blue: 230/255, alpha: 0.6))
        }
        
        verbRanges.forEach { range in
            self.addHighlight(to: range, withColor: UIColor(red: 208/255, green: 2/255, blue: 27/255, alpha: 0.6))
        }
        
        pronounRanges.forEach { range in
            self.addHighlight(to: range, withColor: UIColor(red: 253/255, green: 160/255, blue: 8/255, alpha: 0.6))
        }
        
        adverbRanges.forEach { range in
            self.addHighlight(to: range, withColor: UIColor(red: 108/255, green: 201/255, blue: 7/255, alpha: 0.6))
        }
        
        adjectiveRanges.forEach { range in
            self.addHighlight(to: range, withColor: UIColor(red: 144/255, green: 19/255, blue: 254/255, alpha: 0.6))
        }
    }
    
    private func setupUI() {
        [originalTextView, translatedTextView].forEach {
            $0?.isEditable = false
            $0?.isScrollEnabled = false
        }
        
        originalTextView.font = UIFont.systemFont(ofSize: 17)
        translatedTextView.font = UIFont.italicSystemFont(ofSize: 17)
    }
    
    private func addHighlight(to range: NSRange, withColor color: UIColor) {
        let layoutManager = originalTextView.layoutManager
        
        let text = originalTextView.text!
        
        layoutManager.enumerateLineFragments(forGlyphRange: range) { lineRect, usedRect, textContainer, lineRange, stop in
            let currentRange = NSIntersectionRange(lineRange, range)
            
            var finalLineRect = CGRect.zero
            
            text.enumerateSubstrings(in: Range(currentRange, in: text)!, options: .byComposedCharacterSequences) { substring, substringRange, enclosingRange, stop in
                
                let singleRange = layoutManager.glyphRange(forCharacterRange: NSRange(substringRange, in: substring!), actualCharacterRange: nil)
                let glyphRect = layoutManager.boundingRect(forGlyphRange: singleRange, in: textContainer)
                
                if finalLineRect == .zero {
                    finalLineRect = glyphRect
                } else {
                    finalLineRect.size.width += glyphRect.size.width
                }
            }
            let insets = self.originalTextView.textContainerInset
            finalLineRect.origin.x += insets.left
            finalLineRect.origin.y += insets.top
            
            let roundRect = CALayer()
            roundRect.frame = finalLineRect
            roundRect.bounds = finalLineRect
            
            roundRect.cornerRadius = 4
            roundRect.backgroundColor = color.cgColor
            
            self.originalTextView.layer.addSublayer(roundRect)
        }
    }
}

extension SentenceView: ListViewComponent {
    func update(withViewModel viewModel: Any) {
        guard let viewModel = viewModel as? SentenceViewModel else { return }
        update(with: viewModel)
    }
}
