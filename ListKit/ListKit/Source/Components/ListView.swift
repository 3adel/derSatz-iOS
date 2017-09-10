//
//  Copyright © 2017 Zalando. All rights reserved.
//

import UIKit

public class ListView: UICollectionView {
    
    public var scrollDirection: UICollectionViewScrollDirection {
        get {
            return (collectionViewLayout as? CollectionViewLayout)?.scrollDirection ?? .vertical
        }
        set(scrollDirection) {
            (collectionViewLayout as? CollectionViewLayout)?.scrollDirection = scrollDirection
        }
    }
    
    var collectionViewDataSource: CollectionViewDataSource?
    
    public override var dataSource: UICollectionViewDataSource? {
        get {
            return collectionViewDataSource
        }
        set (dataSource) {
            super.dataSource = collectionViewDataSource
        }
    }
    
    public override var delegate: UICollectionViewDelegate? {
        get {
            return collectionViewDataSource
        }
        set (delegate) {
            super.delegate = collectionViewDataSource
        }
    }
    
    public var onScrollDidEnd: (()->())? {
        get {
            return collectionViewDataSource?.onScrollDidEnd
        }
        set(action) {
            collectionViewDataSource?.onScrollDidEnd = action
        }
    }
    
    public var onItemShown: ((IndexPath) -> ())? {
        get {
            return collectionViewDataSource?.onItemShown
        }
        set(callback) {
            collectionViewDataSource?.onItemShown = callback
        }
    }
    
    public convenience init(frame: CGRect) {
        self.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    public func add(listSection: ListSection) {
        collectionViewDataSource?.add(listSection: listSection, animated: true)
    }
    
    public func update(section: ListSection) {
        collectionViewDataSource?.update(sections: [section], animated: true)
    }
    
    public func update(sections: [ListSection], animated: Bool = true) {
        collectionViewDataSource?.update(sections: sections, animated: animated)
    }
    
    public func add(listFeature: ListFeature) {
        collectionViewDataSource?.add(listFeature: listFeature)
    }
    
    private func setupUI() {
        backgroundColor = .white
        setupDataSource()
    }
    
    private func setupDataSource() {
        collectionViewDataSource = CollectionViewDataSource(collectionView: self)
        dataSource = collectionViewDataSource
        delegate = collectionViewDataSource
    }
}
