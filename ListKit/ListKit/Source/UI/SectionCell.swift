//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

class SectionCell: UICollectionViewCell {
    var sectionView: UIView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sectionView?.frame = contentView.bounds
    }
    
    func update(with sectionView: UIView) {
        self.sectionView = sectionView
        
        contentView.addSubview(sectionView)
        sectionView.frame = contentView.bounds
    }
}

extension SectionCell: ListViewComponent {
    func update(withViewModel viewModel: Any) {
        guard let sectionView = viewModel as? UIView else { return }
        update(with: sectionView)
    }
}
