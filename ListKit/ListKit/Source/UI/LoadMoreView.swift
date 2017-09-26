//
//  Copyright © 2016 Zalando. All rights reserved.
//

import UIKit

public class LoadMoreView : UICollectionReusableView {
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    public func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    public func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    private func setupUI() {
        addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
    }
}

extension LoadMoreView: ListViewComponent {}
