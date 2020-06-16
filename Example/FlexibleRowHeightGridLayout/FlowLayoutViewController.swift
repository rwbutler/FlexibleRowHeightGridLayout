//
//  FlowLayoutViewController.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 08/06/2019.
//  Copyright (c) 2019 Ross Butler. All rights reserved.
//

import UIKit

class FlowLayoutViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let dataSource = DataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(inset: 10.0)
        collectionView.dataSource = dataSource
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
}

extension FlowLayoutViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 100.0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 100.0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return section == 0
        ? UIEdgeInsets(inset: 10.0)
        : UIEdgeInsets.zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return section == 0 ? 10 : 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return section == 0 ? 10 : 0
    }
    
}
