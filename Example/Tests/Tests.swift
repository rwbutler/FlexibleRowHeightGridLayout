import XCTest
import FlexibleRowHeightGridLayout

class TestDelegate: NSObject {
    
    private let heights: [CGFloat] = [
        1.0, 2.0, 3.0, 4.0,
        5.0, 8.0, 7.0, 6.0,
        9.0, 10.0, 11.0, 12.0,
        13.0, 14.0, 65.0, 16.0
    ]
    
}

extension TestDelegate: FlexibleRowHeightGridLayoutDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout: FlexibleRowHeightGridLayout,
        heightForItemAt indexPath: IndexPath
    ) -> CGFloat {
        return heights[indexPath.item]
    }
    
    func numberOfColumns(for size: CGSize) -> Int {
        return 4
    }
    
}

extension TestDelegate: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heights.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
}

class Tests: XCTestCase {
    
    private var collectionView: UICollectionView!
    
    // swiftlint:disable:next weak_delegate
    private var delegate: TestDelegate!
    
    private func makeSUT() -> FlexibleRowHeightGridLayout {
        let layout = FlexibleRowHeightGridLayout()
        delegate = TestDelegate()
        layout.delegate = delegate
        let frame = CGRect(x: 0.0, y: 0.0, width: 1000.0, height: 1000.0)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = delegate
        return layout
    }
    
    func testAllItemsInFirstRowAssignedHeightOfTallestCell() {
        let sut = makeSUT()
        let expectedHeight: CGFloat = 4.0
        let firstItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        let secondItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 1, section: 0))
        let thirdItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 2, section: 0))
        let fourthItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 3, section: 0))
        XCTAssertEqual(firstItemAttrs?.frame.size.height, expectedHeight)
        XCTAssertEqual(secondItemAttrs?.frame.size.height, expectedHeight)
        XCTAssertEqual(thirdItemAttrs?.frame.size.height, expectedHeight)
        XCTAssertEqual(fourthItemAttrs?.frame.size.height, expectedHeight)
    }
    
    func testAllItemsInAMiddleRowAssignedHeightOfTallestCell() {
        let sut = makeSUT()
        let expectedHeight: CGFloat = 8.0
        let firstItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 4, section: 0))
        let secondItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 5, section: 0))
        let thirdItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 6, section: 0))
        let fourthItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 7, section: 0))
        XCTAssertEqual(firstItemAttrs?.frame.size.height, expectedHeight)
        XCTAssertEqual(secondItemAttrs?.frame.size.height, expectedHeight)
        XCTAssertEqual(thirdItemAttrs?.frame.size.height, expectedHeight)
        XCTAssertEqual(fourthItemAttrs?.frame.size.height, expectedHeight)
    }
    
    func testAllItemsInLastRowAssignedHeightOfTallestCell() {
        let sut = makeSUT()
        let expectedHeight: CGFloat = 65.0
        let firstItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 12, section: 0))
        let secondItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 13, section: 0))
        let thirdItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 14, section: 0))
        let fourthItemAttrs = sut.layoutAttributesForItem(at: IndexPath(item: 15, section: 0))
        XCTAssertEqual(firstItemAttrs?.frame.size.height, expectedHeight)
        XCTAssertEqual(secondItemAttrs?.frame.size.height, expectedHeight)
        XCTAssertEqual(thirdItemAttrs?.frame.size.height, expectedHeight)
        XCTAssertEqual(fourthItemAttrs?.frame.size.height, expectedHeight)
    }
    
}
