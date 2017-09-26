//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import Foundation

public protocol UserAction {
    var identifier: String { get }
}

public extension RawRepresentable where RawValue == String, Self: UserAction {
    var identifier: String {
        return self.rawValue
    }
}


public typealias UserActionCallback = (UIControl?, Any?) -> Void
public typealias UserActionCallbackPair = (UserAction, UserActionCallback)

public enum ListViewComponentType {
    case cell, header, footer
}

public protocol ListViewComponent {
    func update(withViewModel viewModel: Any)
    func update(withViewModel viewModel: Any, onSelect: ListSelectionClosure?)
    func update(withStyleModel styleModel: Any)
    func register(action: UserAction, callback: @escaping UserActionCallback)
}

public extension ListViewComponent {
    //Default implementation
    func update(withViewModel viewModel: Any, onSelect: ListSelectionClosure?) {
        update(withViewModel: viewModel)
    }
    func update(withStyleModel styleModel: Any) {}
    func update(withViewModel viewModel: Any) {}
    func register(action: UserAction, callback: @escaping UserActionCallback) {}
}
