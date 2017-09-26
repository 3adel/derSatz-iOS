//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import Foundation

extension IndexPath {
    init(item: Int) {
        self.init(item: item, section: 0)
    }
    
    static var zero: IndexPath {
        return IndexPath(item: 0, section: 0)
    }
}

extension CGRect {
    var rightX: CGFloat {
        return origin.x + size.width
    }
    
    var bottomY: CGFloat {
        return origin.y + size.height
    }
}

extension UINib {
    static func doesExist(withName name: String, in bundle: Bundle = .main) -> Bool {
        let path = bundle.path(forResource: name, ofType: "nib")
        return path != nil
    }
}
