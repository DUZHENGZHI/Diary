//
//  YearMonthCollectionViewCell.swift
//  Diary
//
//  Created by kevinzhow on 15/3/4.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class YearMonthCollectionViewCell: UICollectionViewCell {
    var monthLabel: DiaryLabel!
    
    var monthText: String = "" {
        didSet {
            self.monthLabel.updateText(monthText)
        }
    }
    
    var monthInt: Int = 0
    
    override func awakeFromNib() {
        
        self.monthLabel = DiaryLabel(fontname: "Wyue-GutiFangsong-NC", labelText: monthText, fontSize: 16.0, lineHeight: 5.0)
        
        self.addSubview(monthLabel)
    }
}
