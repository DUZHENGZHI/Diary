//
//  DiaryHelper.swift
//  Diary
//
//  Created by kevinzhow on 15/2/11.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

func sizeHeightWithText(labelText: NSString, fontSize: CGFloat, textAttributes: [NSObject : AnyObject]) -> CGRect {
    
    return labelText.boundingRectWithSize(CGSizeMake(fontSize, 480), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
}

extension UILabel {
    
    convenience init(fontname:String ,labelText:String, fontSize : CGFloat){
        let font = UIFont(name: fontname, size: fontSize) as UIFont!
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let textAttributes: [NSObject : AnyObject] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]
        var labelSize = sizeHeightWithText(labelText, fontSize ,textAttributes)
        
        self.init(frame: labelSize)
        
        self.attributedText = NSAttributedString(string: labelText, attributes: textAttributes)
        self.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.numberOfLines = 0
    }
    
    public func resizeLabelWithFontName(fontname:String ,labelText:String, fontSize : CGFloat){
        let font = UIFont(name: fontname, size: fontSize) as UIFont!
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let textAttributes: [NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.blackColor(),  NSParagraphStyleAttributeName: paragraphStyle]
        var labelSize = sizeHeightWithText(labelText, fontSize ,textAttributes)
        
        self.frame = CGRectMake(0, 0, labelSize.width, labelSize.height)
        
        self.attributedText = NSAttributedString(string: labelText, attributes: textAttributes)
        self.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.numberOfLines = 0
    }
}
