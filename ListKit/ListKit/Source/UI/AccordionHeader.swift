//
//  Copyright © 2017 Zalando. All rights reserved.
//

import Foundation

public protocol AccordionHeader {
    var tag: Int { get set }
    var onDidTap: ((Int) -> ())? { get set }
}
