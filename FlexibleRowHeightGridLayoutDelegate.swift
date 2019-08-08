//
//  FlexibleRowHeightGridLayoutDelegate.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 8/6/19.
//

import Foundation

@objc public protocol FlexibleRowHeightGridLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, referenceHeightForHeaderInSection section: Int) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, referenceHeightForFooterInSection section: Int) -> CGFloat
    func numberOfColumns(for size: CGSize) -> Int
}
