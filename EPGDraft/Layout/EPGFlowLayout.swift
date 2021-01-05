//
//  EPGFlowLayout.swift
//  EPGDraft
//
//  Created by Hussein Jaber on 30/12/2020.
//

import UIKit

protocol EPGFlowLayoutDataSource: AnyObject {
    func collectionView(_ collectionView: UICollectionView, startDateAtIndexPath indexPath: IndexPath) -> Date
    func collectionView(_ collectionView: UICollectionView, endDateAtIndexPath indexPath: IndexPath) -> Date
}

final class EPGFlowLayout: UICollectionViewLayout {

    // MARK: Element
    enum Element: String {
        case sectionHeader
        case cell
        case timeHeader
        
        var id: String {
            self.rawValue
        }
        
        var kind: String {
            "Kind\(self.rawValue.capitalized)"
        }
    }
    
    // MARK: Data source
    weak var dataSource: EPGFlowLayoutDataSource?
    
    // MARK: Properties
    override class var layoutAttributesClass: AnyClass {
        EPGLayoutAttributes.self
    }
    
    override var collectionViewContentSize: CGSize {
        .init(width: collectionViewContentWidth, height: contentHeight)
    }
    
    private var collectionViewContentWidth: CGFloat {
        guard let collectionView = collectionView,
              collectionView.numberOfSections > 0 else {
            return .zero
        }
        let numberOfItemsInSection = collectionView.numberOfItems(inSection: 0)
        let sectionHeaderWidth = sectionHeaderSize.width
        let itemWidth = CGFloat(numberOfItemsInSection) * settings.fullItemSize.width
        return sectionHeaderWidth + itemWidth
    }
    
    private var settings = EPGLayoutSettings()
    
    private var oldBounds = CGRect.zero
    private var contentHeight = CGFloat()
    private var cache: [Element: [IndexPath: EPGLayoutAttributes]] = [:]
    private var visibleLayoutAttributes = [EPGLayoutAttributes]()
    private var zIndex = 0
    
    private var collectionViewHeight: CGFloat {
        collectionView!.frame.height
    }
    
    private var collectionViewWidth: CGFloat {
        collectionView!.frame.width
    }
    
    private var sectionHeaderSize: CGSize {
        guard let sectionHeaderSize = settings.sectionHeaderSize else {
            return .zero
        }
        return sectionHeaderSize
    }
    
    private var contentOffset: CGPoint {
        collectionView!.contentOffset
    }
}

extension EPGFlowLayout {
    
    // MARK: - Helper Functions
    /// Difference between end date and start date for an item at a specific indexPath
    /// - Parameter indexPath: The indexPath of the item
    /// - Returns: Difference in seconds
    private func dateDifferenceForItemAt(indexPath: IndexPath) -> Double {
        guard let collectionView = collectionView, dataSource != nil else {
            fatalError("Datasource not assigned")
        }
        let startDate = dataSource!.collectionView(collectionView,
                                                   startDateAtIndexPath: indexPath).timeIntervalSince1970 / 60
        let endDate = dataSource!.collectionView(collectionView,
                                                 endDateAtIndexPath: indexPath).timeIntervalSince1970 / 60
        return endDate - startDate
    }

    
    /// Returns the width of all the previous items at a specific index
    /// - Parameter indexPath: indexPath of the item which wants the width of all the previous items
    /// - Returns: Sum of all width, zero in case the item has no previous ones
    private func widthOfPreviousItemsAt(indexPath: IndexPath) -> CGFloat {
        guard indexPath.item > 0 else {
            return .zero
        }
        var width: CGFloat = 0
        
        width += sectionHeaderSize.width
        for item in 0..<indexPath.item {
            width += cache[.cell]![IndexPath(item: item, section: indexPath.section)]!.size.width
        }
        
        return width
    }
    
    
    /// Returns the size of the item based on the time duration of the item
    /// - Parameter difference: Difference between the end/start date of the item, i.e. duration
    /// - Returns: Size
    private func itemSizeForDateDifference(_ difference: Double) -> CGSize {
        if difference <= 30 {
            return settings.itemSize
        } else {
            return settings.fullItemSize
        }
    }
}

// MARK: - Overriding
extension EPGFlowLayout {
    
    // MARK: Prepare
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else {
            return
        }
        
        prepareCache()
        contentHeight = 0
        zIndex = 0
        oldBounds = collectionView.bounds

        prepareTimeHeaderView()
        
        for section in 0..<collectionView.numberOfSections {
            let sectionHeaderAttributes = EPGLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: .init(item: 0, section: section))
            
            prepareSectionHeader(size: sectionHeaderSize,
                           attributes: sectionHeaderAttributes, section: section)
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            for item in 0..<numberOfItems {
                let cellIndexPath = IndexPath(item: item, section: section)
                
               
                let difference = dateDifferenceForItemAt(indexPath: cellIndexPath)
                let itemSize: CGSize = itemSizeForDateDifference(difference)
                
                let attributes = EPGLayoutAttributes(forCellWith: cellIndexPath)

                var newX: CGFloat
                if item == 0 {
                    newX = sectionHeaderSize.width + settings.minimumInteritemSpacing
                } else {
                    newX = settings.minimumInteritemSpacing + widthOfPreviousItemsAt(indexPath: cellIndexPath)
                }

                let newY = CGFloat(section) * sectionHeaderSize.height + settings.timeHeaderItemSize.height
                attributes.frame = CGRect(x: newX,
                                          y: newY,
                                          width: itemSize.width,
                                          height: itemSize.height)
                attributes.zIndex = numberOfItems - item
                contentHeight = attributes.frame.maxY
                cache[.cell]?[cellIndexPath] = attributes
            }
        }
    }
    
    
    /// Removes all cached layout attributes
    private func prepareCache() {
        cache.removeAll(keepingCapacity: true)
        cache[.sectionHeader] = [IndexPath: EPGLayoutAttributes]()
        cache[.cell] = [IndexPath: EPGLayoutAttributes]()
        cache[.timeHeader] = [IndexPath: EPGLayoutAttributes]()
    }
    
    
    /// Prepares all section headers and caches all the attributes
    /// - Parameters:
    ///   - size: Size of the section header
    ///   - attributes: Attributes of the section header that should be prepared
    ///   - section: Specifies the sections number
    private func prepareSectionHeader(size: CGSize, attributes: EPGLayoutAttributes, section: Int) {
        guard size != .zero else {
            return
        }
        let contentHeight = size.height * CGFloat(section) + settings.timeHeaderItemSize.height
        attributes.initialOrigin = CGPoint(x: 0, y: contentHeight)
        attributes.frame = .init(origin: attributes.initialOrigin, size: size)
        
        attributes.zIndex = 1000
        
        self.contentHeight = attributes.frame.maxY
        cache[.sectionHeader]?[attributes.indexPath] = attributes
    }
    
    /// Prepares the time line header view of the collection view and caches it
    private func prepareTimeHeaderView() {
        guard let collectionView = collectionView else { return }
        let numberOfRowsInSection = collectionView.numberOfItems(inSection: 0)
        var originalX = sectionHeaderSize.width
        for index in 0..<numberOfRowsInSection {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = EPGLayoutAttributes(forSupplementaryViewOfKind: Element.timeHeader.kind, with: indexPath)
            attributes.frame = .init(origin: .init(x: originalX, y: 0), size: settings.timeHeaderItemSize)
            attributes.zIndex = 100
            cache[.timeHeader]?[indexPath] = attributes
            originalX += settings.timeHeaderItemSize.width
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            cache.removeAll(keepingCapacity: true)
        }
        return true
    }
}

// MARK: - Override layout attributes implementation
extension EPGFlowLayout {
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return cache[.sectionHeader]?[indexPath]
        case Element.timeHeader.kind:
            return cache[.timeHeader]?[indexPath]
        default:
            return nil
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache[.cell]?[indexPath]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }
        visibleLayoutAttributes.removeAll(keepingCapacity: true)
        
        var headerNeedingLayout = IndexSet()
        
        for (_, elementInfos) in cache {
            for (_, attributes) in elementInfos {

                if attributes.frame.intersects(rect) {
                    visibleLayoutAttributes.append(attributes)
                }
                if attributes.representedElementCategory == .cell {

                    headerNeedingLayout.insert(attributes.indexPath.section)
                }
                if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                    headerNeedingLayout.remove(attributes.indexPath.section)
                }
            }
        }
        
        headerNeedingLayout.forEach({ index in
            let indexPath = IndexPath(item: 0, section: index)
            let attributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
            cache[.sectionHeader]?[indexPath] = attributes as? EPGLayoutAttributes
        })
        
        for (type, elementInfo) in cache where type == .sectionHeader {
            
            for (_, attributes) in elementInfo {
                let section = attributes.indexPath.section
                _ = layoutAttributesForItem(at: .init(item: 0, section: section))
                let attributesForLastItemInSection = layoutAttributesForItem(at: .init(item: collectionView.numberOfItems(inSection: section) - 1, section: section))
                var frame = attributes.frame
                let offSet = contentOffset.x
                
                let minX: CGFloat = 0
                let maxX = attributesForLastItemInSection!.frame.maxX
                
                let x = min(max(offSet, minX), maxX)
                frame.origin.x = x
                attributes.frame = frame
                attributes.zIndex = .max
                
            }
        }
        return visibleLayoutAttributes
    }
    
    
    /// Target content offset: used to paginate the collection
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var result = super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                               withScrollingVelocity: velocity)
        guard let collectionView = collectionView else {
            return result
        }

        let targetRect = CGRect(origin: result, size: collectionView.bounds.size)
        let layoutAttributes = layoutAttributesForElements(in: targetRect)?
            .filter({ $0.representedElementKind == Element.timeHeader.kind })            
            .sorted { $0.frame.minX < $1.frame.minX }
        
        // 1. fetch the first two visible items attributes, if not found return the default result
        guard let first = layoutAttributes?.first, let second = layoutAttributes?.second else {
            return result
        }

        // 2. couple of attributes with the difference between their x point and the proposed offset x point
        // we should set the offset to the couple which is the nearest to the proposed point
        let firstCouple: (CGFloat, UICollectionViewLayoutAttributes) = (abs(proposedContentOffset.x - first.frame.origin.x), first)
        let secondCouple: (CGFloat, UICollectionViewLayoutAttributes) =  (abs(proposedContentOffset.x - second.frame.origin.x), second)
        
        let couples = [firstCouple, secondCouple]
        // 3. we get the minimum here
        let min_ = min(firstCouple.0, secondCouple.0)
        // 4. then select the couple that has the minumum value
        let selectedOne = couples.first(where: { $0.0 == min_ })
        // 5. and alter the initial result here, taking into consideration the section header size
        result = .init(x: selectedOne!.1.frame.origin.x - sectionHeaderSize.width, y: proposedContentOffset.y)

        return result
    }
}

extension Array {
    var second: Element? {
        if indices.count > 1 {
            return self[1]
        }
        return nil
    }
}
