//
//  FilterCollectionViewCell.swift
//  ImageFilterEditor
//
//  Created by David Wright on 5/7/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView! {
           didSet {
               configureCell()
           }
       }
    
    @IBOutlet weak var filterSFSymbolImageView: UIImageView!
    
    private func configureCell() {
        let bgViewWidth = bgView.bounds.width
        
        bgView.layer.cornerRadius = bgViewWidth * 0.5
        bgView.layer.borderWidth = bgViewWidth * 0.025
        bgView.layer.borderColor = UIColor.lightGray.cgColor
        bgView.layer.masksToBounds = true
    }
}
