//
//  DiaryLayout.swift
//  Diary
//
//  Created by kevinzhow on 15/2/16.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

var edgeInsets = (screenRect.width - collectionViewWidth)/2.0

class DiaryLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        super.prepareLayout()
        let itemSize = CGSizeMake(itemWidth, itemHeight)
        self.itemSize = itemSize
        self.minimumInteritemSpacing = 0.0
        self.minimumLineSpacing = itemSpacing
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
        let layoutAttributes = super.layoutAttributesForElementsInRect(rect) as! [UICollectionViewLayoutAttributes]
        let contentOffset = collectionView!.contentOffset

        
        for (index, attributes) in enumerate(layoutAttributes) {
            
            let center = attributes.center
            
            let cellPositinOnScreen = (center.x - itemWidth/2.0) - contentOffset.x
            
            if cellPositinOnScreen >= edgeInsets && cellPositinOnScreen < (edgeInsets + collectionViewWidth) {
                attributes.alpha = 1
            } else {
                attributes.alpha = 0
            }
            
            
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
