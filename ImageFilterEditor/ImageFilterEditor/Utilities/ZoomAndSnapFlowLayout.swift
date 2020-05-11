//
//  ZoomAndSnapFlowLayout.swift
//  ImageFilterEditor
//
//  Created by David Wright on 5/10/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

import UIKit

class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {

    let zoomFactor: CGFloat = 0.3
    let numberOfItemsToFitOnScreen: CGFloat = 5
    let itemSpacing: CGFloat = 16
    
    override var itemSize: CGSize {
        didSet {
            guard let collectionView = collectionView else { return }
            collectionView.reloadData()
        }
    }
    
    var indexOfCenterItem: Int? {
        guard let collectionView = collectionView else { return nil }
        return collectionView.indexPathForItem(at: CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY))?.item
    }

    override init() {
        super.init()
        setupDefaultLayoutAttributes()
    }

    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        setupDefaultLayoutAttributes()
    }
    
    private func setupDefaultLayoutAttributes() {
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        minimumInteritemSpacing = itemSpacing
        
        guard let collectionView = collectionView else { return }

        let itemWidth = (collectionView.frame.width / numberOfItemsToFitOnScreen) - minimumInteritemSpacing
        let maxItemHeight = collectionView.frame.height / (1 + zoomFactor)
        if itemWidth > maxItemHeight {
            itemSize = CGSize(width: maxItemHeight, height: maxItemHeight)
            minimumInteritemSpacing = (collectionView.frame.width / numberOfItemsToFitOnScreen) - itemSize.width
        } else {
            itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
    }

    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        
        minimumInteritemSpacing = itemSpacing
        let itemWidth = (collectionView.frame.width / numberOfItemsToFitOnScreen) - minimumInteritemSpacing
        let maxItemHeight = collectionView.frame.height / (1 + zoomFactor)
        if itemWidth > maxItemHeight {
            itemSize = CGSize(width: maxItemHeight, height: maxItemHeight)
            minimumInteritemSpacing = (collectionView.frame.width / numberOfItemsToFitOnScreen) - itemSize.width
        } else {
            itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
        
        let horizontalInset = (collectionView.frame.width - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        
        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        let activeDistance: CGFloat = (itemSize.width / 1.5) + minimumInteritemSpacing

        // Make the cells be zoomed when they reach the center of the screen
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance

            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
            }
        }

        return rectAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

        // Add some snapping behavior so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
}
