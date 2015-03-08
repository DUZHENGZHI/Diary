//
//  HomeYearCollectionViewCell.swift
//  Diary
//
//  Created by kevinzhow on 15/2/11.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class HomeYearCollectionViewCell: DiaryCollectionViewCell {
    
    
    override func awakeFromNib() {
        
        self.textLabel = DiaryLabel(fontname: "TpldKhangXiDictTrial", labelText: labelText, fontSize: 16.0,lineHeight: 5.0)
        
        self.addSubview(textLabel)
    }
    
    override func layoutSubviews() {
        
        self.textLabel.center = CGPointMake(20.0/2.0, 150.0/2.0)
    }
    
    
}
