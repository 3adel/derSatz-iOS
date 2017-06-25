//
//  SeparatorFooterView.swift
//  ListKit
//
//  Created by Halil Gursoy on 05/04/2017.
//  Copyright © 2017 Halil Gursoy. All rights reserved.
//

import Foundation

class SeparatorFooterView: UICollectionReusableView {
    private let separatorLine = UIView()
    
    var color: UIColor? {
        get {
            return separatorLine.backgroundColor
        }
        set(value) {
            separatorLine.backgroundColor = value
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setInsets(_ edgeInsets: UIEdgeInsets) {
        var newFrame = bounds
        newFrame.origin.x += edgeInsets.left
        newFrame.size.width -= edgeInsets.left + edgeInsets.right
        separatorLine.frame = newFrame
    }
    
    private func setupUI() {
        separatorLine.frame = bounds
        addSubview(separatorLine)
    }
}

extension SeparatorFooterView: ListViewComponent {}
