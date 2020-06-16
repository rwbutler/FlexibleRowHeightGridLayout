//
//  FlexibleRowHeightGridLayout.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 8/6/19.
//

import Foundation
import UIKit

public class FlexibleRowHeightGridLayout: UICollectionViewLayout {
    
    // MARK: Type Definitions
    public typealias Delegate = FlexibleRowHeightGridLayoutDelegate
    
    // MARK: - State
    
    /// Content size of the UICollectionView.
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    /// Height of the UICollectionView content.
    private var contentHeight: CGFloat = 0
    
    /// Width of the UICollectionView content.
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let contentInset = collectionView.contentInset
        return collectionView.bounds.size.width - (contentInset.left + contentInset.right)
    }
    
    /// Layout delegate required to determine heights of individual UICollectionViewCells.
    @objc public weak var delegate: Delegate?
    
    /// Layout attributes for positioning UICollectionViewCells.
    private var headerLayoutAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var layoutAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var footerLayoutAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    
    /// The minimum spacing to use between lines of items in the grid.
    @objc public var minimumLineSpacing: CGFloat = 0
    
    // The minimum spacing to use between items in the same row.
    @objc public var minimumInteritemSpacing: CGFloat = 0
    
    // The margin for items within a section.
    @objc public var sectionInset: UIEdgeInsets = UIEdgeInsets.zero
    
    // MARK: - Lifecycle
    public override init() {
        super.init()
        addObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObservers()
    }
    
    /// Removes the layout as an observer from NotificationCenter (not strictly needed from iOS 9 onwards).
    deinit {
        let orientationChangedNotification = UIDevice.orientationDidChangeNotification
        let sizeCategoryChangedNotification = UIContentSizeCategory.didChangeNotification
        NotificationCenter.default.removeObserver(self, name: orientationChangedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: sizeCategoryChangedNotification, object: nil)
    }
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        clearLayoutAttributes()
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes? {
            if elementKind == UICollectionView.elementKindSectionHeader {
                if let collectionView = self.collectionView, headerLayoutAttributes[indexPath] != nil {
                    updateLayoutAttributes(for: collectionView)
                }
                return headerLayoutAttributes[indexPath]
            }
            if elementKind == UICollectionView.elementKindSectionFooter {
                if let collectionView = self.collectionView, footerLayoutAttributes[indexPath] != nil {
                    updateLayoutAttributes(for: collectionView)
                }
                return footerLayoutAttributes[indexPath]
            }
            return nil
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let collectionView = self.collectionView, layoutAttributes.isEmpty {
            updateLayoutAttributes(for: collectionView)
        }
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in headerLayoutAttributes.values {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        for attributes in layoutAttributes.values {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        for attributes in footerLayoutAttributes.values {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.item >= layoutAttributes.count, let collectionView = self.collectionView {
            updateLayoutAttributes(for: collectionView)
        }
        return layoutAttributes[indexPath]
    }
    
    override public func prepare() {
        guard let collectionView = collectionView, layoutAttributes.isEmpty else { return }
        updateLayoutAttributes(for: collectionView)
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let oldBounds = collectionView?.bounds else {
            return false
        }
        return newBounds.width != oldBounds.width
    }
    
}

public extension FlexibleRowHeightGridLayout {
    
    func columnWidth(for section: Int) -> CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        return columnWidth(for: section, in: collectionView)
    }
    
    func labelHeight(_ label: UILabel, width: CGFloat? = nil, in section: Int) -> CGFloat {
        let font = label.font ?? UIFont.preferredFont(forTextStyle: .body)
        let text = label.text ?? ""
        let width = width ?? columnWidth(for: section)
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = label.numberOfLines == 1
            ? [.usesFontLeading]
            : [.usesLineFragmentOrigin, .usesFontLeading]
        let height = text.boundingRect(with: size, options: options,
                                       attributes: [.font: font], context: nil).height
        return ceil(height)
    }
    
    func textHeight(_ text: String, font: UIFont, width: CGFloat? = nil, in section: Int) -> CGFloat {
        let width = width ?? columnWidth(for: section)
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let height = text.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading],
                                       attributes: [.font: font], context: nil).height
        return ceil(height)
    }
    
}

private extension FlexibleRowHeightGridLayout {
    
    /// Adds the layout as an observer for `UIContentSizeCategory.didChangeNotification`.
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeDidChange(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }
    
    /// Clears previously calculated layout attributes.
    private func clearLayoutAttributes() {
        headerLayoutAttributes = [:]
        layoutAttributes = [:]
        footerLayoutAttributes = [:]
    }
    
    /// Retrieves the number of columns in the grid layout.
    private func columnCount(contentSize: CGSize) -> Int {
        let defaultNumberOfColumns = 2
        var numberOfColumns = delegate?.numberOfColumns(for: contentSize) ?? defaultNumberOfColumns
        if numberOfColumns <= 0 {
            numberOfColumns = defaultNumberOfColumns
        }
        return numberOfColumns
    }
    
    /// Calculates the width of a column within the given section.
    private func columnWidth(for section: Int, in collectionView: UICollectionView) -> CGFloat {
        let contentInset = collectionView.contentInset
        let numberOfColumns = CGFloat(columnCount(contentSize: collectionView.bounds.size))
        let sectionInset = self.sectionInset(for: section, in: collectionView)
        let sectionSpacing = minInterItemSpacing(for: section, in: collectionView) * (numberOfColumns - 1)
        let sectionWidth = collectionView.bounds.width
            - (sectionInset.left + sectionInset.right + sectionSpacing + contentInset.left + contentInset.right)
        return sectionWidth / numberOfColumns
    }
    
    /// Calculates the x-coordinates for the given number of columns with the specified width and spacing.
    private func columnXCoordinates(columnCount: Int, columnWidth: CGFloat, spacing: CGFloat) -> [CGFloat] {
        var xOffset = [CGFloat]()
        (0 ..< columnCount).forEach {
            let columnIndex = CGFloat($0)
            xOffset.append((columnIndex * columnWidth) + (columnIndex * spacing))
        }
        return xOffset
    }
    
    /// Invoked for changes in `UIContentSizeCategory`.
    @objc func contentSizeDidChange(_ notification: Notification) {
        guard let collectionView = collectionView else {
            return
        }
        updateLayoutAttributes(for: collectionView)
        collectionView.reloadData()
    }
    
    /// Calculates the indices that represent the cells in the same row as the specified index.
    /// - parameters:
    ///     - index: Index in the row to retrieve indices for.
    ///     - itemsPerRow: Number of items in a row.
    /// - returns: The indices in the same row as `index`.
    private func indicesInSameRow(as index: Int, itemsPerRow: Int) -> [Int] {
        let rowNumber = index / itemsPerRow
        let rowStartIndex = rowNumber * itemsPerRow
        let range = rowStartIndex..<(rowStartIndex + itemsPerRow)
        return Array(range)
    }
    
    /// Returns indices in the specified array less than the value of `index`.
    /// - parameters:
    ///     - index: Index for which indices with a lesser value should be returned.
    ///     - indices: The array of indices to be filtered.
    /// - returns: Indices with a value less than `index`.
    private func indicesLessThan(index: Int, in indices: [Int]) -> [Int] {
        return indices.filter { $0 < index }
    }
    
    /// Retrieves the minimum spacing between items for the given section.
    private func minInterItemSpacing(for section: Int, in collectionView: UICollectionView) -> CGFloat {
        return delegate?.collectionView?(
            collectionView,
            layout: self,
            minimumInteritemSpacingForSectionAt: section
            ) ?? minimumInteritemSpacing
    }
    
    /// Retrieves the minimum spacing between lines for the given section.
    private func minLineSpacing(for section: Int, in collectionView: UICollectionView) -> CGFloat {
        return delegate?.collectionView?(
            collectionView,
            layout: self,
            minimumLineSpacingForSectionAt: section
            ) ?? minimumLineSpacing
    }
    
    /// Indices of cells whose heights should be compared against that of the current cell to determine the height of
    /// the new cell.
    private func neighboringIndicesLessThan(index: Int, itemsPerRow: Int) -> [Int] {
        let sameRowIndices = indicesInSameRow(as: index, itemsPerRow: itemsPerRow)
        let indicesLessThanCurrent = indicesLessThan(index: index, in: sameRowIndices)
        return indicesLessThanCurrent
    }
    
    /// Retrieves the `UIEdgeInsets` for the specified section.
    private func sectionInset(for section: Int, in collectionView: UICollectionView) -> UIEdgeInsets {
        return delegate?.collectionView?(
            collectionView,
            layout: self,
            insetForSectionAt: section
            ) ?? self.sectionInset
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func updateLayoutAttributes(for collectionView: UICollectionView) {
        clearLayoutAttributes()
        
        // Compute properties needed to determine layout attributes.
        let numberOfColumns = columnCount(contentSize: collectionView.bounds.size)
        var yOffset: CGFloat = 0.0
        
        let sectionsCount = collectionView.numberOfSections
        for sectionIndex in 0..<sectionsCount {
            let sectionInsets = sectionInset(for: sectionIndex, in: collectionView)
            
            let minInterItemSpacing = self.minInterItemSpacing(for: sectionIndex, in: collectionView)
            let minLineSpacing = self.minLineSpacing(for: sectionIndex, in: collectionView)
            let columnWidth = self.columnWidth(for: sectionIndex, in: collectionView)
            let xOffset: [CGFloat] = columnXCoordinates(
                columnCount: numberOfColumns,
                columnWidth: columnWidth,
                spacing: minInterItemSpacing
            )
            let headerIdxPath = IndexPath(item: 0, section: sectionIndex)
            
            // Layout headers.
            let sectionIndexPath = IndexPath(item: 0, section: sectionIndex)
            let headerSize = delegate?.collectionView?(
                collectionView,
                layout: self,
                referenceSizeForHeaderInSection: sectionIndex
            )
            if let headerSize = headerSize, headerSize.height > 0.0 {
                let kind = UICollectionView.elementKindSectionHeader
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind,
                                                                  with: sectionIndexPath)
                let frame = CGRect(x: xOffset[0], y: yOffset, width: headerSize.width, height: headerSize.height)
                attributes.frame = frame
                headerLayoutAttributes[headerIdxPath] = attributes
                yOffset += headerSize.height
                if sectionIndex != 0 {
                    yOffset += minLineSpacing
                }
            }
            
            // Account for section inset from header.
            yOffset += sectionInsets.top
            
            // Layout items in section.
            let itemsInSection = collectionView.numberOfItems(inSection: sectionIndex)
            for itemIdx in 0..<itemsInSection {
                let columnIdx = itemIdx % numberOfColumns
                let indexPath = IndexPath(item: itemIdx, section: sectionIndex)
                let itemHeight = delegate?.collectionView(collectionView, layout: self, heightForItemAt: indexPath) ?? 0
                
                // Calculate maximum height in row (so far).
                let neighbors = neighboringIndicesLessThan(index: itemIdx, itemsPerRow: numberOfColumns)
                let itemHeightsInRow = neighbors.compactMap {
                    let neighboringIdxPath = IndexPath(item: $0, section: sectionIndex)
                    let attrs = layoutAttributes[neighboringIdxPath]?.frame.height
                    return attrs
                    } + [itemHeight]
                let maxItemHeightInRow = itemHeightsInRow.reduce(0.0) { (maxValue, nextValue) in
                    return (nextValue > maxValue) ? nextValue : maxValue
                }
                
                // Update the current UICollectionViewCell frame.
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let leftOffset = xOffset[columnIdx] + sectionInsets.left
                let topOffset = yOffset
                
                let frame = CGRect(x: leftOffset, y: topOffset, width: columnWidth, height: maxItemHeightInRow)
                attributes.frame = frame
                layoutAttributes[indexPath] = attributes
                
                // Update frames for other UICollectionViewCells in row.
                for neighbor in neighbors {
                    let neighboringIdxPath = IndexPath(item: neighbor, section: sectionIndex)
                    if let attributes = layoutAttributes[neighboringIdxPath] {
                        let frame = attributes.frame
                        let updatedSize = CGSize(width: frame.width, height: maxItemHeightInRow)
                        attributes.frame = CGRect(origin: frame.origin, size: updatedSize)
                        layoutAttributes[neighboringIdxPath] = attributes
                    }
                }
                
                // Update yOffset on last item in row.
                let isLastColumn = (columnIdx == (numberOfColumns - 1))
                if isLastColumn {
                    yOffset += maxItemHeightInRow + minLineSpacing
                }
                let isLastItemInSection = itemIdx == itemsInSection - 1
                if isLastItemInSection {
                    let columnNum = itemIdx + 1 // One-based index
                    if columnNum % numberOfColumns != 0 {
                        yOffset += (frame.height + minLineSpacing)
                    }
                }
            }
            
            // Layout footers.
            let footerSize = delegate?.collectionView?(
                collectionView,
                layout: self,
                referenceSizeForFooterInSection: sectionIndex
            )
            if let footerSize = footerSize, footerSize.height > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind:
                    UICollectionView.elementKindSectionFooter, with: sectionIndexPath)
                let frame = CGRect(
                    x: xOffset[0],
                    y: yOffset + sectionInsets.top + sectionInsets.bottom,
                    width: footerSize.width,
                    height: footerSize.height
                )
                attributes.frame = frame
                footerLayoutAttributes[headerIdxPath] = attributes
                yOffset += footerSize.height
                if sectionIndex != (sectionsCount - 1) {
                    yOffset += minLineSpacing
                }
            }
        }
        contentHeight = yOffset
    }
    
}
