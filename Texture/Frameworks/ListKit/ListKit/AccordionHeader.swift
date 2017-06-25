//
//  Copyright © 2017 Halil Gursoy. All rights reserved.
//

import Foundation

public protocol AccordionHeader {
    var tag: Int { get set }
    var onDidTap: ((Int) -> ())? { get set }
}
