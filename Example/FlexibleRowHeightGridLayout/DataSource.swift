//
//  DataSource.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 8/9/19.
//  Copyright © 2019 Ross Butler. All rights reserved.
//

import Foundation
import UIKit

class DataSource: NSObject {
    
    private let strings = [
        "Short text", "Short text", "Short text", "Some longer text which needs more room", "Short text", "Short text",
        "Short text",
        "This is a sentence which requires more space and therefore the height of the cell will be taller.",
        "Short text", "Short text", "Short text", "Short text", "Short text", "Short text", "Short text", "Short text",
        "Short text", "Short text", "Some longer text which needs more room.", "Short text", "Short text", "Short text"
    ]
    
    func item(at index: Int) -> String {
        return strings[index]
    }
    
    func numberOfItems() -> Int {
        return strings.count
    }
    
}

extension DataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let cell = dequeuedCell as? Cell else { return dequeuedCell }
        let text = item(at: indexPath.item)
        cell.label.text = text
        switch text.count {
        case 0...10:
            cell.contentView.backgroundColor = .green
        case 11...40:
            cell.contentView.backgroundColor = .orange
        default:
            cell.contentView.backgroundColor = .red
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems()
    }
    
}
