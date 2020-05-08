//
//  Filter.swift
//  ImageFilterEditor
//
//  Created by David Wright on 5/8/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation
import CoreImage.CIFilterBuiltins

class Filter {
    
    let title: String
    let sfSymbolName: String
    let filter: CIFilter
    var isEnabled: Bool
    var sliderValue: Float?
    
    init(title: String, sfSymbolName: String, filter: CIFilter, isEnabled: Bool, sliderValue: Float? = nil) {
        self.title = title
        self.sfSymbolName = sfSymbolName
        self.filter = filter
        self.sliderValue = sliderValue
        self.isEnabled = isEnabled
    }
}


extension Filter {
    
    static let invertColors = Filter(title: "Invert Colors",
                                     sfSymbolName: "circle.righthalf.fill",
                                     filter: CIFilter.colorInvert(),
                                     isEnabled: false)
    
    static let vignette = Filter(title: "Vignette",
                                 sfSymbolName: "timelapse",
                                 filter: CIFilter.vignette(),
                                 isEnabled: false,
                                 sliderValue: 0)
    
    static let sketchify = Filter(title: "Sketchify",
                                  sfSymbolName: "scribble",
                                  filter: CIFilter.lineOverlay(),
                                  isEnabled: false,
                                  sliderValue: 0)
    
    static let sketchify2 = Filter(title: "Sketchify",
                                   sfSymbolName: "pencil.and.outline",
                                   filter: CIFilter.lineOverlay(),
                                   isEnabled: false,
                                   sliderValue: 0)
    
    static let kaleidoscope = Filter(title: "Kaleidoscope",
                                     sfSymbolName: "circle.grid.hex",
                                     filter: CIFilter.kaleidoscope(),
                                     isEnabled: false,
                                     sliderValue: 0)
    
    static let perspectiveTransform = Filter(title: "Perspective",
                                             sfSymbolName: "perspective",
                                             filter: CIFilter.perspectiveTransform(),
                                             isEnabled: false,
                                             sliderValue: 0.5)
}
