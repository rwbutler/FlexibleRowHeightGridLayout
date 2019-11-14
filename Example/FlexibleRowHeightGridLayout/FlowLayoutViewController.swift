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
        collectionView.dataSource = dataSource
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
}
