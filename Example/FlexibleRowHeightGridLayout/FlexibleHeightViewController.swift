//
//  FlexibleHeightViewController.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 8/9/19.
//  Copyright © 2019 Ross Butler. All rights reserved.
//

import Foundation
import UIKit
import FlexibleRowHeightGridLayout

class FlexibleHeightViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let dataSource = DataSource()
    
    override func viewDidLoad() {
        collectionView.dataSource = dataSource
        collectionView.contentInset = UIEdgeInsets(inset: 10.0)
        collectionView.register(
            Header.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.register(
            Footer.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "footer"
        )
        let layout = FlexibleRowHeightGridLayout()
        layout.delegate = self
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        collectionView.collectionViewLayout = layout
    }
    
}

extension FlexibleHeightViewController: FlexibleRowHeightGridLayoutDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout: FlexibleRowHeightGridLayout,
        heightForItemAt indexPath: IndexPath
    ) -> CGFloat {
        let text = dataSource.item(at: indexPath)
        let font = UIFont.preferredFont(forTextStyle: .body)
        return layout.textHeight(text, font: font, in: indexPath.section)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout: FlexibleRowHeightGridLayout,
        minimumInteritemSpacingForSectionAt: Int
    ) -> CGFloat {
        return minimumInteritemSpacingForSectionAt == 0 ? 10 : 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout: FlexibleRowHeightGridLayout,
        minimumLineSpacingForSectionAt: Int
    ) -> CGFloat {
        return minimumLineSpacingForSectionAt == 0 ? 10 : 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout: FlexibleRowHeightGridLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return section == 0
            ? UIEdgeInsets(inset: 10.0)
            : UIEdgeInsets.zero
    }
    
    func numberOfColumns(for size: CGSize) -> Int {
        return 5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout: FlexibleRowHeightGridLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: layout.collectionViewContentSize.width, height: 100.0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout: FlexibleRowHeightGridLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        return CGSize(width: layout.collectionViewContentSize.width, height: 100.0)
    }
    
}
