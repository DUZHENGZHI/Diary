//
//  DiaryHelper.swift
//  Diary
//
//  Created by kevinzhow on 15/2/11.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

func diaryButtonWith(#text: String, #fontSize: CGFloat, #width: CGFloat, #normalImageName: String, #highlightedImageName: String) -> UIButton {
    
    var button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    button.frame = CGRectMake(0, 0, width, width)
    
    var font = UIFont(name: "Wyue-GutiFangsong-NC", size: fontSize) as UIFont!
    let textAttributes: [NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
    var attributedText = NSAttributedString(string: text, attributes: textAttributes)
    button.setAttributedTitle(attributedText, forState: UIControlState.Normal)
    
    button.setBackgroundImage(UIImage(named: normalImageName), forState: UIControlState.Normal)
    button.setBackgroundImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
    
    return button

}