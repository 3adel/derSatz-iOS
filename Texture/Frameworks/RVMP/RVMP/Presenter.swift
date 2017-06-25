//
//  Copyright © 2017 Zalando. All rights reserved.
//

import Foundation

open class Presenter: BasePresenter {
    public var router: Router?
    public var view: View?
    
    public required init(router: Router? = nil) {
        self.router = router
    }
    
    open func viewDidAppear() {}
    open func getInitialData() {}
}

