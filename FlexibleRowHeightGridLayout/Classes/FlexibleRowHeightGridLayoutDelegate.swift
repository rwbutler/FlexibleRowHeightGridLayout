//
//  FlexibleRowHeightGridLayoutDelegate.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 8/6/19.
//

import Foundation
import UIKit

@objc public protocol FlexibleRowHeightGridLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout,
                        heightForItemAt indexPath: IndexPath) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout,
                                       referenceHeightForHeaderInSection section: Int) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout,
                                       referenceHeightForFooterInSection section: Int) -> CGFloat
    func numberOfColumns(for size: CGSize) -> Int
}
