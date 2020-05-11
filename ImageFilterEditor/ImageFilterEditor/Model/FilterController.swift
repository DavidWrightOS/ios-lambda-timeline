//
//  FilterController.swift
//  ImageFilterEditor
//
//  Created by David Wright on 5/10/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation
import CoreImage.CIFilterBuiltins

class FilterController {
    
    var filters: [Filter]
    
    init() {
        self.filters = [
            Filter.invertColors,
            Filter.vignette,
            Filter.lineOverlay,
            Filter.kaleidoscope,
            Filter.perspectiveTransform
        ]
    }
}
