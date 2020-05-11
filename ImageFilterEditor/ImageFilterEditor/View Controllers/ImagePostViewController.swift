//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by David Wright on 5/7/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

/*
protocol ImageFilterable {
    func filteredImage(inputImage: CIImage) -> CIImage
    func resetFilterSettings()
}
*/

class ImagePostViewController: UIViewController {
    
    let filterController = FilterController()
    private let context = CIContext()
    
    var currentFilter: Filter! {
        didSet {
            updateCurrentFilter()
        }
    }
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale: CGFloat = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width*scale,
                                height: scaledSize.height*scale)
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else { return }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    private let flowLayout = ZoomAndSnapFlowLayout()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var filterSlider: UISlider!
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var filterTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        filterCollectionView.collectionViewLayout = flowLayout
        filterCollectionView.decelerationRate = .fast
        
        currentFilter = Filter.invertColors
        originalImage = imageView.image
    }
    
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        presentImagePickerController()
    }
    
    @IBAction func filterSwitchChanged(_ sender: UISwitch) {
        currentFilter.isEnabled = sender.isOn
        updateImage()
    }
    
    @IBAction func filterSliderValueChanged(_ sender: UISlider) {
        currentFilter.sliderValue = sender.value
        updateImage()
    }
    
    private func updateCurrentFilter() {
        filterTitleLabel.text = currentFilter.title
        if let sliderValue = currentFilter.sliderValue {
            filterSlider.isHidden = false
            filterSwitch.isHidden = true
            filterSlider.value = sliderValue
        } else {
            filterSlider.isHidden = true
            filterSwitch.isHidden = false
            filterSwitch.isOn = currentFilter.isEnabled
        }
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        var outputImage = inputImage
        
        /*
        for filter in filterController.filters {
            outputImage = filter.filteredImage(inputImage: outputImage)
        }
        */
        
        let invertColorsFilter = CIFilter.colorInvert()
        let vignetteFilter = CIFilter.vignette()
        let lineOverlayFilter = CIFilter.lineOverlay()
        let kaleidoscopeFilter = CIFilter.kaleidoscope()
        let perspectiveTransformFilter = CIFilter.perspectiveTransform()
        
        // Invert Colors
        if filterController.filters[0].isEnabled {
            invertColorsFilter.inputImage = outputImage
            guard let filteredImage = invertColorsFilter.outputImage else { return originalImage! }
            outputImage = filteredImage
        }

        // Vignette
        if let sliderValue = filterController.filters[1].sliderValue, sliderValue > 0 {
            vignetteFilter.inputImage = outputImage
            vignetteFilter.radius = sliderValue * 100
            vignetteFilter.intensity = sliderValue * 2
            if let filteredImage = vignetteFilter.outputImage {
                outputImage = filteredImage
            }
        }

        // Line Overlay (Sketchify)
        if let sliderValue = filterController.filters[2].sliderValue, sliderValue > 0 {
            lineOverlayFilter.setValue(outputImage, forKey: kCIInputImageKey)
            lineOverlayFilter.nrNoiseLevel = 0.09 - (sliderValue * 0.09)
            lineOverlayFilter.edgeIntensity = 0.5 + (sliderValue * 2.0)
            lineOverlayFilter.threshold = 0.5 - (sliderValue * 0.4)
            if let filteredImage = lineOverlayFilter.outputImage {
                outputImage = filteredImage
            }
        }

        // Kaleidoscope
        if let sliderValue = filterController.filters[3].sliderValue, sliderValue > 0 {
            kaleidoscopeFilter.setValue(outputImage, forKey: kCIInputImageKey)
            kaleidoscopeFilter.angle = sliderValue * Float.pi * 4
            kaleidoscopeFilter.count = Int(sliderValue * 20)
            kaleidoscopeFilter.center = CGPoint(x: outputImage.extent.midX,
                                                y: outputImage.extent.midY)
            if let filteredImage = kaleidoscopeFilter.outputImage {
                outputImage = filteredImage
            }
        }

        // PerspectiveTransform
        if let sliderValue = filterController.filters[4].sliderValue {
            perspectiveTransformFilter.inputImage = outputImage
            let imageAspectRatio = outputImage.extent.width / outputImage.extent.height
            let leftSideYOffset: CGFloat = sliderValue > 0.5 ? 0 : (CGFloat(0.5 - sliderValue) * 500)
            let rightSideYOffset: CGFloat = sliderValue < 0.5 ? 0 : (CGFloat(sliderValue - 0.5) * 500)
            let leftSideXOffset: CGFloat = imageAspectRatio * leftSideYOffset * 2
            let rightSideXOffset: CGFloat = imageAspectRatio * rightSideYOffset * 2
            perspectiveTransformFilter.bottomLeft = CGPoint(x: outputImage.extent.minX + leftSideXOffset,
                                                            y: outputImage.extent.minY + leftSideYOffset)
            perspectiveTransformFilter.bottomRight = CGPoint(x: outputImage.extent.maxX - rightSideXOffset,
                                                             y: outputImage.extent.minY + rightSideYOffset)
            perspectiveTransformFilter.topLeft = CGPoint(x: outputImage.extent.minX + leftSideXOffset,
                                                         y: outputImage.extent.maxY - leftSideYOffset)
            perspectiveTransformFilter.topRight = CGPoint(x: outputImage.extent.maxX - rightSideXOffset,
                                                          y: outputImage.extent.maxY - rightSideYOffset)
            if let filteredImage = perspectiveTransformFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        // I could not figure out how to get the crystalize and pointillize filters to work
        
        // Crystalize
        /*
        if slider2.value > 0 {
            //crystalizeFilter.inputImage = outputImage
            crystalizeFilter.setValue(outputImage, forKey: kCIInputImageKey)
            crystalizeFilter.radius = slider2.value * 10
            crystalizeFilter.center = CGPoint(x: outputImage.extent.midX,
                                              y: outputImage.extent.midY)
            if let filteredImage = crystalizeFilter.outputImage {
                outputImage = filteredImage
            }
        }
        */
        
        // Pointillize
        /*
        if slider2.value > 0 {
            //crystalizeFilter.inputImage = outputImage
            pointillizeFilter.setValue(outputImage, forKey: kCIInputImageKey)
            pointillizeFilter.radius = slider2.value * 60
            pointillizeFilter.center = CGPoint(x: outputImage.extent.midX,
                                               y: outputImage.extent.midY)
            if let filteredImage = pointillizeFilter.outputImage {
                outputImage = filteredImage
            }
        }
        */
        
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return originalImage! }
        
        return UIImage(cgImage: renderedImage)
    }
}


// MARK: UICollectionViewDataSource

extension ImagePostViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterController.filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCollectionViewCell else { return UICollectionViewCell() }
    
        let sfSymbolImage = UIImage(systemName: filterController.filters[indexPath.item].sfSymbolName)!
        cell.filterSFSymbolImageView.image = sfSymbolImage
    
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension ImagePostViewController: UICollectionViewDelegate, UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let index = flowLayout.indexOfCenterItem {
            currentFilter = filterController.filters[index]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentFilter = filterController.filters[indexPath.item]
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: UIImagePickerControllerDelegate

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
