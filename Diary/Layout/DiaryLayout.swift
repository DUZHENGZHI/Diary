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
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
    }
    
    override func collectionViewContentSize() -> CGSize {
        let cells = collectionView!.numberOfItemsInSection(0)
        let contentSize = CGSizeMake((CGFloat(cells) * itemWidth) + edgeInsets*2, screenRect.height)
//        println("Content Size is \(contentSize.width)")
        return contentSize
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        
        let layoutAttributes = super.layoutAttributesForElementsInRect(rect) as! [UICollectionViewLayoutAttributes]
        let collectionViewFrame = collectionView!.frame
        let contentInset = collectionView!.contentInset
        let contentOffset = collectionView!.contentOffset
        
        println(rect)
//        println("Cells Count \(collectionView!.numberOfItemsInSection(0)) layoutAttributes Count \(layoutAttributes.count) last")
        
        for (index, attributes) in enumerate(layoutAttributes) {
            
            var frame = attributes.frame
            var center = attributes.center
            
            center.x = edgeInsets + itemWidth/2.0 +  itemWidth * CGFloat(attributes.indexPath.row)
            
            let cellPositinOnScreen = (center.x - itemWidth/2.0) - contentOffset.x
            
            if cellPositinOnScreen >= edgeInsets && cellPositinOnScreen < (edgeInsets + collectionViewWidth) {
                attributes.alpha = 1
            } else {
                attributes.alpha = 0
            }
            
            center.y = collectionViewFrame.size.height/2.0
//            println("Index Path is \(attributes.indexPath.row) y is \(center.y) x is \(center.x)")
            
            attributes.frame = frame
            attributes.center = center
            
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
