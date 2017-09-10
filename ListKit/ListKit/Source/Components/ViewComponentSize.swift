//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import Foundation

public enum ViewComponentSizeType {
    case absolute, relative
}

public protocol ViewComponentSizeProtocol {
    var indentLevel: Int { get }
    func calculateActualSize(in frame: CGRect?) -> CGSize
}

extension ViewComponentSizeProtocol {
    public var indentLevel: Int {
        return 0
    }
}

public struct GridViewComponentSize: ViewComponentSizeProtocol {
    let numberOfItemsPerRow: Int
    let aspectRatio: CGFloat
    let horizontalPadding: CGFloat
    let additionalHeight: CGFloat
    let interitemSpacing: CGFloat
    
    public init(numberOfItemsPerRow: Int,
                aspectRatio: CGFloat = 1,
                horizontalPadding: CGFloat = 0,
                additionalHeight: CGFloat = 0,
                interitemSpacing:CGFloat = 0) {
        self.numberOfItemsPerRow = numberOfItemsPerRow
        self.aspectRatio = aspectRatio
        self.horizontalPadding = horizontalPadding
        self.additionalHeight = additionalHeight
        self.interitemSpacing = interitemSpacing
    }
    
    
    public func calculateActualSize(in frame: CGRect? = nil) -> CGSize {
        guard let frame = frame else { return .zero }
        
        let numberOfItems = CGFloat(numberOfItemsPerRow)
        let allInteritemSpacing = interitemSpacing * (numberOfItems - 1)
        let width = floor((frame.width - (horizontalPadding * 2) - allInteritemSpacing) / numberOfItems)
        
        let height = width / aspectRatio + additionalHeight
        return CGSize(width: width, height: height)
        
    }
    
    public func byChangingNumberOfItemsPerRow(to numberOfItemsPerRow: Int) -> GridViewComponentSize {
        return GridViewComponentSize(numberOfItemsPerRow: numberOfItemsPerRow,
                                     aspectRatio: aspectRatio,
                                     horizontalPadding: horizontalPadding,
                                     additionalHeight: additionalHeight,
                                     interitemSpacing: interitemSpacing)
    }
}

public struct ViewComponentSize: ViewComponentSizeProtocol {
    public let size: CGSize
    public let additionalSize: CGSize
    public let aspectRatio: CGFloat?
    public let edgeInsets: UIEdgeInsets
    public let indentLevel: Int
    public let widthType: ViewComponentSizeType
    public let heightType: ViewComponentSizeType
    
    public init(size: CGSize, additionalSize: CGSize = .zero, aspectRatio: CGFloat? = nil, widthType: ViewComponentSizeType, heightType: ViewComponentSizeType, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.size = size
        self.additionalSize = additionalSize
        self.aspectRatio = aspectRatio
        self.widthType = widthType
        self.heightType = heightType
        self.edgeInsets = edgeInsets
        self.indentLevel = indentLevel
    }
    
    public init(size: CGSize, additionalSize: CGSize = .zero, type: ViewComponentSizeType = .absolute, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.init(size: size,
                  additionalSize: additionalSize,
                  widthType: type,
                  heightType: type,
                  edgeInsets: edgeInsets)
    }
    
    public init(height: CGFloat, additionalHeight: CGFloat = 0, type: ViewComponentSizeType = .absolute, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.init(size: CGSize(width: 1, height: height),
                  additionalSize: CGSize(width: 0, height: additionalHeight),
                  widthType: .relative,
                  heightType: type,
                  edgeInsets: edgeInsets,
                  indentLevel: indentLevel)
    }
    
    public init(width: CGFloat, widthType: ViewComponentSizeType = .absolute,  aspectRatio: CGFloat, additionalHeight: CGFloat = 0, edgeInsets: UIEdgeInsets = .zero, indentLevel: Int = 0) {
        self.size = CGSize(width: width, height: 0)
        self.additionalSize = CGSize(width: 0, height: additionalHeight)
        self.aspectRatio = aspectRatio
        self.widthType = widthType
        self.heightType = .relative
        self.edgeInsets = edgeInsets
        self.indentLevel = indentLevel
    }
    
    public func calculateActualSize(in frame: CGRect? = nil) -> CGSize {
        if widthType == .absolute && heightType == .absolute {
            return size
        }
        guard let frame = frame else { return .zero }
        
        let width = widthType == .relative ? frame.width * size.width : size.width
        
        let height: CGFloat
        if let aspectRatio = aspectRatio {
            height = width / aspectRatio
        } else {
            height = heightType == .relative ? frame.height * size.height : size.height
        }
        
        return CGSize(width: width + additionalSize.width, height: height + additionalSize.height)
    }
    
    public static let zero: ViewComponentSizeProtocol = ViewComponentSize(size: .zero, type: .absolute)
}
