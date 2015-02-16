//
//  HomeYearCollectionViewCell.swift
//  Diary
//
//  Created by kevinzhow on 15/2/11.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class HomeYearCollectionViewCell: UICollectionViewCell {
    
    var yearLabel: UILabel!
    
    var yearText: String = "二零一五年"
    
    override func awakeFromNib() {
        
        self.yearLabel = UILabel(fontname: "STSongti-SC-Bold", labelText: yearText, fontSize: 16.0)
        
        self.addSubview(yearLabel)
    }
    
    
    
}
