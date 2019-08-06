//
//  FlexibleRowHeightGridLayoutDelegate.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 8/6/19.
//

import Foundation

@objc public protocol FlexibleRowHeightGridLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
    func numberOfColumns(for size: CGSize) -> Int
}
