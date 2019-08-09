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
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    /// Layout delegate required to determine heights of individual UICollectionViewCells.
    @objc public weak var delegate: Delegate?
    
    /// Layout attributes for positioning UICollectionViewCells.
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    /// Previous device orientation.
    private var previousOrientation: UIDeviceOrientation?
    
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
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let collectionView = self.collectionView {
            updateLayoutAttributes(for: collectionView)
        }
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in layoutAttributes {
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
        return layoutAttributes[indexPath.item]
    }
    
    override public func prepare() {
        guard let collectionView = collectionView, layoutAttributes.isEmpty else { return }
        updateLayoutAttributes(for: collectionView)
    }
    
}

public extension FlexibleRowHeightGridLayout {
    
    func columnWidth() -> CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let numberOfColumns = columnCount(contentSize: collectionView.bounds.size)
        return contentWidth / CGFloat(numberOfColumns)
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
        let orientationChangedNotification = UIDevice.orientationDidChangeNotification
        let sizeCategoryChangedNotification = UIContentSizeCategory.didChangeNotification
        notificationCenter.addObserver(self, selector: #selector(orientationDidChange(_:)),
                                       name: orientationChangedNotification, object: nil)
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
    
    @objc func orientationDidChange(_ notification: Notification) {
        let supportedOrientations: [UIDeviceOrientation] = [.landscapeLeft, .landscapeRight, .portrait, .portraitUpsideDown]
        guard let orientation = (notification.object as? UIDevice)?.orientation,
            supportedOrientations.contains(orientation) else {
                return
        }
        if let previous = previousOrientation {
            guard previous != orientation else { return }
            updateLayoutAttributes()
        } else {
            updateLayoutAttributes()
        }
        previousOrientation = orientation
    }
    
    private func updateLayoutAttributes() {
        guard let collectionView = collectionView else { return }
        updateLayoutAttributes(for: collectionView)
        collectionView.reloadData()
    }
    
    private func updateLayoutAttributes(for collectionView: UICollectionView) {
        layoutAttributes = [] // Empty existing attributes.
        
        // Compute properties needed to determine layout attributes.
        let numberOfColumns = columnCount(contentSize: collectionView.bounds.size)
        let columnWidth = self.columnWidth()
        var xOffset: [CGFloat] = xOffsets(columnCount: numberOfColumns, columnWidth: columnWidth)
        var yOffset: CGFloat = 0
        
        let sectionsCount = collectionView.numberOfSections
        for sectionIdx in 0..<sectionsCount {
            // Layout headers.
            let sectionIndexPath = IndexPath(item: 0, section: sectionIdx)
            if let headerHeight = delegate?.collectionView?(collectionView, layout: self, referenceHeightForHeaderInSection: sectionIdx), headerHeight > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: sectionIndexPath)
                let frame = CGRect(x: 0.0, y: yOffset, width: contentWidth, height: headerHeight)
                attributes.frame = frame
                layoutAttributes.append(attributes)
                yOffset += headerHeight
            }
            // Layout items in section.
            let itemsInSection = collectionView.numberOfItems(inSection: sectionIdx)
            for itemIdx in 0..<itemsInSection {
                let columnIdx = itemIdx % numberOfColumns
                let indexPath = IndexPath(item: itemIdx, section: sectionIdx)
                let itemHeight = delegate?.collectionView(collectionView, layout: self, heightForItemAt: indexPath) ?? 0
                
                // Calculate maximum height in row (so far).
                let neighbors = neighboringIndicesLessThan(index: itemIdx, itemsPerRow: numberOfColumns)
                let itemHeightsInRow = neighbors.map { layoutAttributes[$0].frame.height } + [itemHeight]
                let maxItemHeightInRow = itemHeightsInRow.reduce(0.0) { (maxValue, nextValue) in
                    return (nextValue > maxValue) ? nextValue : maxValue
                }
                
                // Update the current UICollectionViewCell frame.
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let frame = CGRect(x: xOffset[columnIdx], y: yOffset, width: columnWidth, height: maxItemHeightInRow)
                attributes.frame = frame
                layoutAttributes.append(attributes)
                
                // Update frames for other UICollectionViewCells in row.
                for neighbor in neighbors {
                    let attributes = layoutAttributes[neighbor]
                    let frame = attributes.frame
                    let updatedSize = CGSize(width: frame.width, height: maxItemHeightInRow)
                    attributes.frame = CGRect(origin: frame.origin, size: updatedSize)
                    layoutAttributes[neighbor] = attributes
                }
                
                // Update yOffset on last item in row.
                let isLastColumn = (columnIdx == (numberOfColumns - 1))
                if isLastColumn {
                    yOffset += maxItemHeightInRow
                }
                let isLastItemInSection = itemIdx == itemsInSection - 1
                if isLastItemInSection {
                    let columnNum = itemIdx + 1 // One-based index
                    if columnNum % numberOfColumns != 0 {
                        yOffset += frame.height
                    }
                }
            }
            // Layout footers.
            if let footerHeight = delegate?.collectionView?(collectionView, layout: self, referenceHeightForFooterInSection: sectionIdx), footerHeight > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: sectionIndexPath)
                let frame = CGRect(x: 0.0, y: yOffset, width: contentWidth, height: footerHeight)
                attributes.frame = frame
                layoutAttributes.append(attributes)
                yOffset += footerHeight
            }
        }
        contentHeight = yOffset
    }
    
    private func xOffsets(columnCount: Int, columnWidth: CGFloat) -> [CGFloat] {
        var xOffset = [CGFloat]()
        for column in 0 ..< columnCount {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        return xOffset
    }
    
}
