//
//  HomeYearCollectionViewCell.swift
//  Diary
//
//  Created by kevinzhow on 15/2/11.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class HomeYearCollectionViewCell: UICollectionViewCell {
    
    var yearLabel: DiaryLabel!
    
    var yearText: String = "" {
        didSet {
            self.yearLabel.updateText(yearText)
        }
    }
    
    var yearInt: Int = 0
    
    override func awakeFromNib() {
        
        self.yearLabel = DiaryLabel(fontname: "TpldKhangXiDictTrial", labelText: yearText, fontSize: 16.0,lineHeight: 5.0)
        
        self.addSubview(yearLabel)
    }
    
    override func layoutSubviews() {
        
        self.yearLabel.center = CGPointMake(20.0/2.0, 150.0/2.0)
    }
    
}
