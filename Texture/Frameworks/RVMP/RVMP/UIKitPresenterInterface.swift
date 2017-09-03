//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

extension UIView: ViewComponent { }

extension UIViewController: BaseView {
    open func showLoader() {}
    
    open func hideLoader() {}
    
    open func disableUserInteractions() {
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    open func enableUserInteractions() {
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    open func show(errorMessage: String?) {}
    
    open func show(infoMessage: String?) {}
    
    open func showAlert(title: String? = nil, message: String? = nil, actions: [(title: String, completion: VoidFunction?)] = [], cancelAction: (title: String, completion: VoidFunction?)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: .default) { _ in
                action.completion?()
            }
            alert.addAction(alertAction)
        }
        
        if let cancelAction = cancelAction {
            let cancelAlertAction = UIAlertAction(title: cancelAction.title, style: .cancel) { _ in
                cancelAction.completion?()
            }
            alert.addAction(cancelAlertAction)
        }
        
        present(alert, animated: true, completion: nil)
    }

}
