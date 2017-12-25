import UIKit

/**
 Handle constraints programmatically
 */

public extension UIView {
    
    enum ViewAnchor {
        case top
        case right
        case bottom
        case left
        
        enum LayoutType {
            case vertical, horizontal
        }
        
        var layoutType: LayoutType {
            switch self {
            case .top, .bottom: return .vertical
            case .left, .right: return .horizontal
            }
        }
        
        fileprivate func constraint(fromView view1: UIView, toView view2: UIView, to viewAnchor: ViewAnchor? = nil) -> NSLayoutConstraint? {
            let fromAnchor = self
            let toAnchor = viewAnchor ?? self
            
            guard fromAnchor.layoutType == toAnchor.layoutType else { return nil }
            
            var constraint: NSLayoutConstraint? = nil
            
            switch self.layoutType {
            case .horizontal:
                guard let anchor1 = view1.horizontalLayoutAnchor(for: fromAnchor),
                    let anchor2 = view2.horizontalLayoutAnchor(for: toAnchor) else { break }
                
                constraint = anchor1.constraint(equalTo: anchor2)
            case .vertical:
                guard let anchor1 = view1.verticalLayoutAnchor(for: fromAnchor),
                    let anchor2 = view2.verticalLayoutAnchor(for: toAnchor) else { break }
                
                constraint = anchor1.constraint(equalTo: anchor2)
            }
            return constraint
        }
        
        fileprivate var anchorMagnitude: CGFloat {
            switch self {
            case .top, .left: return 1
            case .bottom, .right: return -1
            }
        }
    }
    
    fileprivate func verticalLayoutAnchor(for viewAnchor: ViewAnchor) -> NSLayoutYAxisAnchor? {
        switch viewAnchor {
        case .top:
            return topAnchor
        case .bottom:
            return bottomAnchor
        default:
            return nil
        }
    }
    
    fileprivate func horizontalLayoutAnchor(for viewAnchor: ViewAnchor) -> NSLayoutXAxisAnchor? {
        switch viewAnchor {
        case .left:
            return leftAnchor
        case .right:
            return rightAnchor
        default:
            return nil
        }
    }
    
}

public extension UIView {
    
    public func fillInSuperview() {
        fillInSuperviewWithEdgeInset()
    }
    
    public func fillInSuperviewWithEdgeInset(top: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0) {
        guard let _ = superview else { return }
        snap(toSuperviewAnchor: .top, constant: top)
        snap(toSuperviewAnchor: .left, constant: left)
        snap(toSuperviewAnchor: .bottom, constant: bottom)
        snap(toSuperviewAnchor: .right, constant: right)
    }
    
    public func centerInSuperview() {
        centerHorizontallyInSuperview()
        centerVerticallyInSuperview()
    }
    
    @discardableResult
    public func snap(toSuperviewAnchor anchor: ViewAnchor, constant: CGFloat = 0) -> NSLayoutConstraint? {
        guard let superview = superview else { return nil }
        return snap(toView: superview, anchor: anchor, constant: constant)
    }
    
    @discardableResult
    public func snap(toView view: UIView, anchor: ViewAnchor, constant: CGFloat = 0) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = anchor.constraint(fromView: self, toView: view)
        constraint?.constant = anchor.anchorMagnitude * constant
        constraint?.isActive = true
        return constraint
    }
    
    @discardableResult
    public func snap(_ fromAnchor: ViewAnchor, to toAnchor: ViewAnchor, of view: UIView, withMargin margin: CGFloat = 0) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = fromAnchor.constraint(fromView: self, toView: view, to: toAnchor)
        constraint?.constant = fromAnchor.anchorMagnitude * margin
        constraint?.isActive = true
        return constraint
    }
    
    @discardableResult
    public func snap(topToViewController viewController: UIViewController) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: viewController.topLayoutGuide.bottomAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func centerHorizontallyInSuperview() -> NSLayoutConstraint? {
        guard let superview = superview else { return nil }
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func centerVerticallyInSuperview() -> NSLayoutConstraint? {
        guard let superview = superview else { return nil }
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func setSquareAspectRatio() -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1)
        constraint.isActive = true
        return constraint
    }
    
    public func snapToSuperview() {
        let anchors: [ViewAnchor] = [.top, .left, .right, .bottom]
        
        anchors.forEach { anchor in
            snap(toSuperviewAnchor: anchor)
        }
    }
}

extension UIView {
    
    @discardableResult
    public func setWidth(equalToView view: UIView?, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint? {
        guard let view = view else { return nil }
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func setWidth(equalToConstant width: CGFloat) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalToConstant: width)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func setHeight(equalToView view: UIView?, multiplier: CGFloat = 1) -> NSLayoutConstraint? {
        guard let view = view else { return nil }
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplier)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func setHeight(equalToConstant height: CGFloat) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalToConstant: height)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func centerVertically(with view: UIView) -> NSLayoutConstraint? {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerYAnchor.constraint(equalTo: view.centerYAnchor)
        constraint.isActive = true
        return constraint
    }
}

extension UIView {
    @discardableResult
    public func placeOnTop(ofView view: UIView?, space: CGFloat = 0.0) -> NSLayoutConstraint? {
        guard let view = view else { return nil }
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: -space)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func placeOnBottom(ofView view: UIView?, space: CGFloat = 0.0) -> NSLayoutConstraint? {
        guard let view = view else { return nil }
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: space)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func placeOnRight(ofView view: UIView?, space: CGFloat = 0.0) -> NSLayoutConstraint? {
        guard let view = view else { return nil }
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: space)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func placeOnLeft(ofView view: UIView?, space: CGFloat = 0.0) -> NSLayoutConstraint? {
        guard let view = view else { return nil }
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: -space)
        constraint.isActive = true
        return constraint
    }
}

