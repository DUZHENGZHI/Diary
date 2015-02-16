//
//  DiaryLayout.swift
//  Diary
//
//  Created by kevinzhow on 15/2/16.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        super.prepareLayout()
        
        var screenRect = UIScreen.mainScreen().bounds
        var screenWidth = screenRect.size.width
        var screenHeight = screenRect.size.height
        
        var itemHeight = 150.0
        
        self.sectionInset = UIEdgeInsetsMake( (screenHeight - 150.0) / 2.0 , 0, 0, 0)
        
        var itemSize = CGSizeMake(20.0, CGFloat( itemHeight))
        
        self.itemSize = itemSize
        
        
        self.minimumInteritemSpacing = 0.0
        self.minimumLineSpacing = 0
    }
}
