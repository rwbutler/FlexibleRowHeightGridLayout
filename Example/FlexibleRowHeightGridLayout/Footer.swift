//
//  Footer.swift
//  FlexibleRowHeightGridLayout
//
//  Created by Ross Butler on 16/06/2020.
//  Copyright © 2020 Ross Butler. All rights reserved.
//

import Foundation
import UIKit

class Footer: UICollectionReusableView {
    
    private let label: UILabel!
    
    override init(frame: CGRect) {
        label = UILabel(frame: frame)
        super.init(frame: frame)
        addLabel()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addLabel() {
        label.backgroundColor = .clear
        label.text = "Section Footer"
        backgroundColor = .purple
        addSubview(label)
    }
    
    private func configureConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
