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
                                       insetForSectionAt: Int) -> UIEdgeInsets
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout,
                                       minimumLineSpacingForSectionAt: Int) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout,
                                       minimumInteritemSpacingForSectionAt: Int) -> CGFloat
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout,
                                       referenceSizeForHeaderInSection section: Int) -> CGSize
    @objc optional func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout,
                                       referenceSizeForFooterInSection section: Int) -> CGSize
    func numberOfColumns(for size: CGSize) -> Int
}
