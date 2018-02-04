//
//  Copyright © 2016 Zalando. All rights reserved.
//

import Foundation

//MARK: Generic View and Presenter protocols

public protocol BaseView: class {
    func showLoader()
    func hideLoader()
    func disableUserInteractions()
    func enableUserInteractions()
    func show(errorMessage: String)
    func show(infoMessage: String)
    func show(successMessage: String)
    func showAlert(title: String?, message: String?, actions: [(title: String, completion: (()->())?)], cancelAction: (title: String, completion: (()->())?)?)
}

public extension BaseView {
    public func showLoader() {}
    public func hideLoader() {}
    public func disableUserInteractions() {}
    public func enableUserInteractions() {}
    public func show(errorMessage: String) {}
    public func show(infoMessage: String) {}
    func show(successMessage: String) {}
    func showAlert(title: String?, message: String?, actions: [(title: String, completion: (()->())?)], cancelAction: (title: String, completion: (()->())?)?) {}
}

public protocol View: BaseView {
    var presenter: BasePresenter? { get set }
}

public protocol ViewComponent: class {}

public protocol BasePresenter: class {
    func getInitialData()
    func viewDidAppear()
}

public protocol PagingCapableViewModel {
    var hasNextPage: Bool { get }
}

