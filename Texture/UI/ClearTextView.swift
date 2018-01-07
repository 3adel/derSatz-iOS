//
//  ClearTextView.swift
//  Texture
//
//  Created by Halil Gursoy on 25.12.17.
//  Copyright © 2017 Texture. All rights reserved.
//

import UIKit

class ClearTextView: UITextView {
    private var clearButton: UIButton
    private var _delegate: UITextViewDelegate?
    private var delegates: [UITextViewDelegate] = []
    
    private var clearButtonTopConstraint: NSLayoutConstraint?
    
    private let edgeInset: CGFloat = 8
    
    override var delegate: UITextViewDelegate? {
        get { return delegates.first }
        set {
            guard let newValue = newValue else { return }
            add(delegate: newValue)
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        clearButton = UIButton(type: .custom)
        super.init(frame: frame, textContainer: textContainer)
        addSubview(clearButton)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        clearButton = UIButton(type: .custom)
        super.init(coder: aDecoder)
        addSubview(clearButton)
        setupUI()
    }
    
    @objc func didTapClearButton() {
        text = ""
        textViewDidChange(self)
        clearButton.isHidden = true
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(self)
        clearButton.isHidden = text.isEmpty
        delegates.forEach {
            if let delegate = $0 as? UITextView,
                delegate === self { return }
            
            $0.textViewDidChange?(self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        clearButtonTopConstraint?.constant = scrollView.contentOffset.y + edgeInset
    }
    
    func add(delegate: UITextViewDelegate) {
        delegates.append(delegate)
    }
    
    private func setupUI() {
        let clearButtonImageSide: CGFloat = 20
        let clearButtonSide: CGFloat = 44
        
        clearButton.setImage(UIImage(named: "clear"), for: .normal)
        clearButton.snap(toSuperviewAnchor: .left, constant: frame.size.width - clearButtonSide - edgeInset)
        clearButtonTopConstraint = clearButton.snap(toSuperviewAnchor: .top, constant: edgeInset)
        clearButton.setHeightConstraint(to: clearButtonSide)
        clearButton.setWidth(equalToConstant: clearButtonSide)
        clearButton.imageEdgeInsets = .init(top: 0, left: 24, bottom: 24, right: 0)
        
        textContainerInset = UIEdgeInsetsMake(edgeInset, 0, edgeInset, clearButtonImageSide + edgeInset)
        
        layoutIfNeeded()
        
        clearButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        clearButton.isHidden = true
        
        super.delegate = self
    }

}
