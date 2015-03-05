//
//  DiaryCollectionViewCell.swift
//  Diary
//
//  Created by kevinzhow on 15/3/4.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
    var textLabel: DiaryLabel!
    
    var labelText: String = "" {
        didSet {
            self.textLabel.updateText(labelText)
        }
    }
    
    var monthInt: Int = 0
    
    override func awakeFromNib() {
        
        self.textLabel = DiaryLabel(fontname: "Wyue-GutiFangsong-NC", labelText: labelText, fontSize: 16.0, lineHeight: 5.0)

        
        self.addSubview(textLabel)
    }
    
}
