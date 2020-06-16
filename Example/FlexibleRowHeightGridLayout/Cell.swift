//
//  Cell.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 8/9/19.
//  Copyright © 2019 Ross Butler. All rights reserved.
//

import Foundation
import UIKit

class Cell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
