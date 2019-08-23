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
        let layout = FlexibleRowHeightGridLayout()
        layout.delegate = self
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 10.0
        collectionView.collectionViewLayout = layout
    }
    
}

extension FlexibleHeightViewController: FlexibleRowHeightGridLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: FlexibleRowHeightGridLayout, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let text = dataSource.item(at: indexPath.item)
        let font = UIFont.preferredFont(forTextStyle: .body)
        return layout.textHeight(text, font: font)
    }
    
    func numberOfColumns(for size: CGSize) -> Int {
        return 5
    }
    
}
