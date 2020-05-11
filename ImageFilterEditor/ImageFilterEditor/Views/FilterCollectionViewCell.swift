//
//  FilterCollectionViewCell.swift
//  ImageFilterEditor
//
//  Created by David Wright on 5/7/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterSFSymbolImageView: UIImageView! {
        didSet {
            configureCell()
        }
    }
    
    private func configureCell() {
        let cellWidth = contentView.frame.size.width
        layer.cornerRadius = cellWidth * 0.5 / 1.3 // TODO: adjust corner radius dynamically based on zoomFactor
        layer.borderWidth = cellWidth * 0.05 / 1.3
        layer.borderColor = UIColor.darkGray.cgColor
        layer.masksToBounds = true
    }
}
