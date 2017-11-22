//
//  Router.swift
//  RVMP
//
//  Created by Halil Gursoy on 03/05/2017.
//  Copyright © 2017 Halil Gursoy. All rights reserved.
//

import UIKit

public struct TabBarSection {
    let title: String
    let imageName: String
    let selectedImageName: String
    let presenterType: Presenter.Type
    let viewControllerType: UIViewController.Type
    
    var image: UIImage? {
        return UIImage(named: imageName.lowercased())
    }
    
    public init(title: String, presenterType: Presenter.Type, viewControllerType: UIViewController.Type,  imageExtension: String) {
        self.title = title
        self.imageName = title+imageExtension
        self.selectedImageName = self.imageName
        self.presenterType = presenterType
        self.viewControllerType = viewControllerType
    }
}

open class Router: BaseRouter {
    public var rootViewController: UIViewController?
    
    public static var shared: Router?
    
    public init(rootViewController: UIViewController? = nil) {
        self.rootViewController = rootViewController
    }
    
    public init(tabs: [TabBarSection], with storyboard: UIStoryboard) {
        setup(tabs: tabs, from: storyboard)
    }
    
    public init(view: View) {
        self.rootViewController = view as? UIViewController
    }
    
    var visibleController: UIViewController {
        return UIWindow.visibleViewController(from: self.rootViewController!)
    }
    
    public func setup(tabs: [TabBarSection], from storyboard: UIStoryboard) {
        let tabBarController = UITabBarController()
        
        var controllers = [UIViewController]()
        tabs.forEach { tab in
            let presenter = tab.presenterType.init(router: self)
            let viewController = storyboard.instantiateViewController(withIdentifier: tab.viewControllerType.Identifier)
            
            guard let view = viewController as? View else { return }
            
            presenter.view = view
            view.presenter = presenter
            
            let tabNavigationController = makeNavigationController(for: viewController)
            
            let tabBarItem = UITabBarItem(title: tab.title, image: tab.image, tag: 0)
            tabNavigationController.tabBarItem = tabBarItem
            
            tabNavigationController.viewControllers.first?.title = tab.title
            controllers.append(tabNavigationController)
        }
        
        tabBarController.viewControllers = controllers
        
        rootViewController = tabBarController
    }
    
    public func present(sheetViewController viewController: UIViewController, sourceView: UIView? = nil, sourceRect: CGRect? = nil) {
        if isPad() {
            viewController.modalPresentationStyle = .popover
            viewController.popoverPresentationController?.sourceView = sourceView
            if let sourceRect = sourceRect {
                viewController.popoverPresentationController?.sourceRect = sourceRect
            }
        }
        rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    public func show(viewController: UIViewController) {
        rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    public func show(view: View) {
        guard let vc = view as? UIViewController else { return }
        show(viewController: vc)
    }
    
    public func dismiss() {
        if let navigationVC = rootViewController?.navigationController {
            navigationVC.popViewController(animated: true)
        } else {
            rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    public func dismissModal() {
        rootViewController?.dismiss(animated: true, completion: nil)
    }
}

public extension Router {
    
    public func makeNavigationController(for viewController: UIViewController) -> UINavigationController {
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.backgroundColor = UIColor.white
        return navigationController
    }
    
    public func present(_ viewController: UIViewController,
                 from sourceView: UIView? = nil,
                 withPresentationStyle presentationStyle: UIModalPresentationStyle = .fullScreen,
                 preferredSize: CGSize = .zero,
                 prefferedOrigin: CGPoint = .zero,
                 anchorFrame: CGRect = .zero,
                 embedInNavigationController: Bool = false,
                 animated: Bool = true,
                 completion: (() -> Swift.Void)? = nil) {
        
        let presentedViewController = embedInNavigationController ? makeNavigationController(for: viewController) : viewController
        
        presentedViewController.modalPresentationStyle = presentationStyle
        
        if presentationStyle == .popover || presentationStyle == .formSheet {
            presentedViewController.preferredContentSize = preferredSize
        }
        
        if let popoverPresentationController = presentedViewController.popoverPresentationController,
            let sourceView = sourceView {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = anchorFrame
        }
        
        visibleController.present(presentedViewController, animated: animated, completion: completion)
    }
    
    public func push(_ viewController: UIViewController) {
        visibleController.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension UIWindow {
    
    class func visibleViewController(from vc: UIViewController) -> UIViewController {
        var visibleController: UIViewController?
        switch vc {
        case let vc as UINavigationController:
            visibleController = vc.visibleViewController
        case let vc as UITabBarController:
            visibleController = vc.selectedViewController!
        case let vc as UISplitViewController:
            if let detailViewController = vc.viewControllers.last {
                visibleController = detailViewController
            }
        case let vc as UISearchController:
            return vc.presentingViewController!
        case let vc where vc.presentedViewController != nil:
            visibleController = vc.presentedViewController!
        default:
            break
        }
        return visibleController != nil ? visibleViewController(from: visibleController!) : vc
    }
}
