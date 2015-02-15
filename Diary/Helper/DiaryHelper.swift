//
//  DiaryHelper.swift
//  Diary
//
//  Created by kevinzhow on 15/2/11.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryHelper: NSObject {
    
    func diaryLabelWithFontSizeAndText(fontSize: CGFloat, labelText: NSString) -> UILabel {
        let label = UILabel(frame: CGRectZero);
        label.font = UIFont (name: "Songti SC Bold", size: fontSize);
        label.sizeToFit();
        return label;
    }
    
}
