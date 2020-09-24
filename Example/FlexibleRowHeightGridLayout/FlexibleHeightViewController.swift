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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkestBlue
        collectionView.backgroundColor = UIColor.darkestBlue
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
        guard let views = Bundle.main.loadNibNamed("Cell", owner: Cell.self, options: nil),
            let cell = views.first as? Cell else {
                return 0
        }
        cell.label.text = dataSource.item(at: indexPath)
        cell.contentView.layoutIfNeeded()
        let size = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: layout.columnWidth(for: indexPath.section),
                   height: UIView.noIntrinsicMetric),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        return size.height
        /*
         Or calculate height without inflating nib as follows:
         let text = dataSource.item(at: indexPath)
         let font = UIFont.preferredFont(forTextStyle: .title3)
         return layout.textHeight(text, font: font, in: indexPath.section)
         */
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
        return traitCollection.horizontalSizeClass == .regular ?  6 : 2
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
