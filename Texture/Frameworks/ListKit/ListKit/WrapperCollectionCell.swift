//
//  WrapperCell.swift
//  ListKit
//
//  Created by Halil Gursoy on 06/04/2017.
//  Copyright © 2017 Halil Gursoy. All rights reserved.
//

import UIKit

class WrapperCollectionCell: UICollectionViewCell {
    var customView: UIView?
    
    override var tag: Int {
        didSet {
            customView?.tag = tag
        }
    }
    
    func set(customView: ListViewComponent) {
        self.customView = customView as! UIView
        
        self.customView?.frame = contentView.bounds
        contentView.addSubview(self.customView!)
        
        self.customView?.tag = tag
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customView?.frame = contentView.bounds
    }
}

extension WrapperCollectionCell: ListViewComponent {
    func update(withViewModel viewModel: Any) {
        let customView = self.customView as? ListViewComponent
        customView?.update(withViewModel: viewModel)
    }
    func update(withViewModel viewModel: Any, onSelect: ListSelectionClosure?) {
        let customView = self.customView as? ListViewComponent
        customView?.update(withViewModel: viewModel, onSelect: onSelect)
    }
    func update(withViewModel viewModel: Any, actions: Any?, onSelect: ListSelectionClosure?) {
        let customView = self.customView as? ListViewComponent
        customView?.update(withViewModel: viewModel, actions: actions, onSelect: onSelect)
    }
}
