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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCell()
    }
    
    private func configureCell() {
        let cellWidth = contentView.frame.size.width
        layer.cornerRadius = cellWidth * 0.5
        layer.borderWidth = cellWidth * 0.04
        layer.borderColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
    }
}
