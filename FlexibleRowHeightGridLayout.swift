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
    override init() {
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
        
        // Set up state
        var column = 0
        layoutAttributes = [] // Empty existing attributes.
        
        // Compute properties needed to determine layout attributes.
        let defaultNumberOfColumns = 2
        var numberOfColumns = delegate?.numberOfColumns(for: collectionView.bounds.size) ?? defaultNumberOfColumns
        if numberOfColumns <= 0 {
            numberOfColumns = defaultNumberOfColumns
        }
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = xOffsets(columnCount: numberOfColumns, columnWidth: columnWidth)
        var yOffset: CGFloat = 0
        
        // This layout only supports 1 section currently
        guard collectionView.numberOfSections == 1 else { return }
        
        // Request height for item in section.
        let itemsInSection = collectionView.numberOfItems(inSection: 0)
        for item in 0..<itemsInSection {
            let indexPath = IndexPath(item: item, section: 0)
            let itemHeight = delegate?.collectionView(collectionView, heightForItemAt: indexPath) ?? 0
            
            // Calculate maximum height in row (so far).
            let neighbors = neighboringIndicesLessThan(index: item, itemsPerRow: numberOfColumns)
            let itemHeightsInRow = neighbors.map { layoutAttributes[$0].frame.height } + [itemHeight]
            let maxItemHeightInRow = itemHeightsInRow.reduce(0.0) { (maxValue, nextValue) in
                return (nextValue > maxValue) ? nextValue : maxValue
            }
            
            // Update the current UICollectionViewCell frame.
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(x: xOffset[column], y: yOffset, width: columnWidth, height: maxItemHeightInRow)
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
            
            // Update column counter.
            if column < (numberOfColumns - 1) {
                column += 1
            } else {
                column = 0
                yOffset += maxItemHeightInRow
            }
            
            // Set content height on reaching the last item.
            if item == itemsInSection - 1 {
                if (item + 1) % numberOfColumns != 0 { // Zero-based index.
                    contentHeight = yOffset + frame.height
                } else {
                    contentHeight = yOffset
                }
            }
        }
    }
    
    private func xOffsets(columnCount: Int, columnWidth: CGFloat) -> [CGFloat] {
        var xOffset = [CGFloat]()
        for column in 0 ..< columnCount {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        return xOffset
    }
    
}
