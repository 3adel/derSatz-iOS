//
//  AnalysisViewController.swift
//  Texture
//
//  Created by Halil Gursoy on 24.06.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit
import RVMP

class AnalysisViewController: UIViewController, AnalysisViewProtocol {
    @IBOutlet weak var textView: UITextView!
    
    var presenter: BasePresenter?
    
    var analysisPresenter: AnalysisPresenterProtocol? {
        return presenter as? AnalysisPresenterProtocol
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.font = UIFont.systemFont(ofSize: 17)
        
        presenter?.getInitialData()
    }
    
    func render(with viewModel: AnalysisViewModel) {
        textView.text = viewModel.text
        
        let nounRanges = viewModel.wordInfos.filter { $0.type == "Noun" }.map { $0.range }
        let verbRanges = viewModel.wordInfos.filter { $0.type == "Verb" }.map { $0.range }
        
        nounRanges.forEach { range in
            self.addHighlight(to: range, withColor: UIColor.blue.withAlphaComponent(0.3))
        }
        
        verbRanges.forEach { range in
            self.addHighlight(to: range, withColor: UIColor.red.withAlphaComponent(0.3))
        }
    }
    
    func addHighlight(to range: NSRange, withColor color: UIColor) {
       let layoutManager = textView.layoutManager
        
        let text = textView.text!
        
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
            let insets = self.textView.textContainerInset
            finalLineRect.origin.x += insets.left
            finalLineRect.origin.y += insets.top
            
            let roundRect = CALayer()
            roundRect.frame = finalLineRect
            roundRect.bounds = finalLineRect
            
            roundRect.cornerRadius = 4
            roundRect.backgroundColor = color.cgColor
            
            self.textView.layer.addSublayer(roundRect)
        }
    }
}
