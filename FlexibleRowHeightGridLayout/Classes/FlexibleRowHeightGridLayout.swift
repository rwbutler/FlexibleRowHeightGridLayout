//
//  FlexibleRowHeightGridLayout.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 8/6/19.
//

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
        let numberOfColumns = CGFloat(columnCount(contentSize: collectionView.bounds.size))
        let spacing = (numberOfColumns - 1) * minimumInteritemSpacing
        return headerWidth - spacing
    }
    
    /// Width of the UICollectionView header
    private var headerWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
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
    
    /// MARK: - Lifecycle
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
        resetLayoutAttributes()
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
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
    
    func columnWidth() -> CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let numberOfColumns = CGFloat(columnCount(contentSize: collectionView.bounds.size))
        return floor(contentWidth / numberOfColumns)
    }
    
    func labelHeight(_ label: UILabel, width: CGFloat? = nil) -> CGFloat {
        let font = label.font ?? UIFont.preferredFont(forTextStyle: .body)
        let text = label.text ?? ""
        let width = width ?? columnWidth()
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = label.numberOfLines == 1
            ? [.usesFontLeading]
            : [.usesLineFragmentOrigin, .usesFontLeading]
        let height = text.boundingRect(with: size, options: options,
                                       attributes: [.font: font], context: nil).height
        return ceil(height)
    }
    
    func textHeight(_ text: String, font: UIFont, width: CGFloat? = nil) -> CGFloat {
        let width = width ?? columnWidth()
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let height = text.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading],
                                       attributes: [.font: font], context: nil).height
        return ceil(height)
    }
    
}

private extension FlexibleRowHeightGridLayout {
    
    private func addObservers() {
        let notificationCenter = NotificationCenter.default
        let sizeCategoryChangedNotification = UIContentSizeCategory.didChangeNotification
        notificationCenter.addObserver(self, selector: #selector(contentSizeDidChange(_:)),
                                       name: sizeCategoryChangedNotification, object: nil)
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
    
    @objc func contentSizeDidChange(_ notification: Notification) {
        updateLayoutAttributes()
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
    
    /// Indices of cells whose heights should be compared against that of the current cell to determine the height of the new cell.
    private func neighboringIndicesLessThan(index: Int, itemsPerRow: Int) -> [Int] {
        let sameRowIndices = indicesInSameRow(as: index, itemsPerRow: itemsPerRow)
        let indicesLessThanCurrent = indicesLessThan(index: index, in: sameRowIndices)
        return indicesLessThanCurrent
    }
    
    /// Clears previously calculated layout attributes.
    private func resetLayoutAttributes() {
        headerLayoutAttributes = [:]
        layoutAttributes = [:]
        footerLayoutAttributes = [:]
    }
    
    private func updateLayoutAttributes() {
        guard let collectionView = collectionView else { return }
        updateLayoutAttributes(for: collectionView)
        collectionView.reloadData()
    }
    
    private func updateLayoutAttributes(for collectionView: UICollectionView) {
        resetLayoutAttributes()
        
        // Compute properties needed to determine layout attributes.
        let numberOfColumns = columnCount(contentSize: collectionView.bounds.size)
        let columnWidth = self.columnWidth()
        let xOffset: [CGFloat] = xOffsets(columnCount: numberOfColumns, columnWidth: columnWidth,
                                          spacing: minimumInteritemSpacing)
        var yOffset: CGFloat = 0.0
        
        let sectionsCount = collectionView.numberOfSections
        for sectionIdx in 0..<sectionsCount {
            let headerIdxPath = IndexPath(item: 0, section: sectionIdx)
            // Layout headers.
            let sectionIndexPath = IndexPath(item: 0, section: sectionIdx)
            if let headerHeight = delegate?.collectionView?(collectionView, layout: self, referenceHeightForHeaderInSection: sectionIdx), headerHeight > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: sectionIndexPath)
                let leftInset = collectionView.contentInset.left
                let frame = CGRect(x: leftInset, y: yOffset, width: headerWidth, height: headerHeight)
                attributes.frame = frame
                headerLayoutAttributes[headerIdxPath] = attributes
                yOffset += headerHeight
                if sectionIdx != 0 {
                    yOffset += minimumLineSpacing
                }
            }
            // Layout items in section.
            let itemsInSection = collectionView.numberOfItems(inSection: sectionIdx)
            for itemIdx in 0..<itemsInSection {
                let columnIdx = itemIdx % numberOfColumns
                let indexPath = IndexPath(item: itemIdx, section: sectionIdx)
                let itemHeight = delegate?.collectionView(collectionView, layout: self, heightForItemAt: indexPath) ?? 0
                
                // Calculate maximum height in row (so far).
                let neighbors = neighboringIndicesLessThan(index: itemIdx, itemsPerRow: numberOfColumns)
                let itemHeightsInRow = neighbors.compactMap {
                    let neighboringIdxPath = IndexPath(item: $0, section: sectionIdx)
                    let attrs = layoutAttributes[neighboringIdxPath]?.frame.height
                    return attrs
                    } + [itemHeight]
                let maxItemHeightInRow = itemHeightsInRow.reduce(0.0) { (maxValue, nextValue) in
                    return (nextValue > maxValue) ? nextValue : maxValue
                }
                
                // Update the current UICollectionViewCell frame.
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let frame = CGRect(x: xOffset[columnIdx], y: yOffset, width: columnWidth, height: maxItemHeightInRow)
                attributes.frame = frame
                layoutAttributes[indexPath] = attributes
                
                // Update frames for other UICollectionViewCells in row.
                for neighbor in neighbors {
                    let neighboringIdxPath = IndexPath(item: neighbor, section: sectionIdx)
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
                    yOffset += maxItemHeightInRow + minimumLineSpacing
                }
                let isLastItemInSection = itemIdx == itemsInSection - 1
                if isLastItemInSection {
                    let columnNum = itemIdx + 1 // One-based index
                    if columnNum % numberOfColumns != 0 {
                        yOffset += (frame.height + minimumLineSpacing)
                    }
                }
            }
            // Layout footers.
            if let footerHeight = delegate?.collectionView?(collectionView, layout: self, referenceHeightForFooterInSection: sectionIdx), footerHeight > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: sectionIndexPath)
                let leftInset = collectionView.contentInset.left
                let frame = CGRect(x: leftInset, y: yOffset, width: headerWidth, height: footerHeight)
                attributes.frame = frame
                footerLayoutAttributes[headerIdxPath] = attributes
                yOffset += footerHeight
                if sectionIdx != (sectionsCount - 1) {
                    yOffset += minimumLineSpacing
                }
            }
        }
        contentHeight = yOffset
    }
    
    private func xOffsets(columnCount: Int, columnWidth: CGFloat, spacing: CGFloat) -> [CGFloat] {
        var xOffset = [CGFloat]()
        for column in 0 ..< columnCount {
            let columnIdx = CGFloat(column)
            xOffset.append((columnIdx * columnWidth) + (columnIdx * spacing))
        }
        return xOffset
    }
    
}
