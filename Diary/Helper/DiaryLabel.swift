//
//  DiaryLabel.swift
//  Diary
//
//  Created by kevinzhow on 15/3/4.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import pop

func sizeHeightWithText(labelText: NSString, fontSize: CGFloat, textAttributes: [NSObject : AnyObject]) -> CGRect {
    
    var rect = labelText.boundingRectWithSize(CGSizeMake(fontSize, 480), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
    rect.size.width = fontSize
    return rect
}

class NumberPaser {
    
    func convertNumber(number:Int) -> String? {
        
        if (number == 0){
            return "零"
        }else{
            return nil
        }
    }
    
}

class DiaryLabel: UILabel {
    
    var textAttributes: [NSObject : AnyObject]!
    
    convenience init(fontname:String ,labelText:String, fontSize : CGFloat, lineHeight: CGFloat){
        
        self.init(frame: CGRectZero)
        
        let font = UIFont(name: fontname, size: fontSize) as UIFont!
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight
        
        textAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle]
        
        var labelSize = sizeHeightWithText(labelText, fontSize ,textAttributes)
        
        self.frame = CGRectMake(0, 0, labelSize.width, labelSize.height)
        
        self.attributedText = NSAttributedString(string: labelText, attributes: textAttributes)
        self.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.numberOfLines = 0
    }
    
    func resizeLabelWithFontName(fontname:String, labelText:String, fontSize : CGFloat, lineHeight: CGFloat ){
        let font = UIFont(name: fontname, size: fontSize) as UIFont!
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight
        
        textAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.blackColor(),  NSParagraphStyleAttributeName: paragraphStyle]
        var labelSize = sizeHeightWithText(labelText, fontSize ,textAttributes)
        
        self.frame = CGRectMake(0, 0, labelSize.width, labelSize.height)
        
        self.attributedText = NSAttributedString(string: labelText, attributes: textAttributes)
        self.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.numberOfLines = 0
    }
    
    func updateText(labelText: String) {

        var labelSize = sizeHeightWithText(labelText, self.font.pointSize ,textAttributes)
        self.frame = CGRectMake(0, 0, labelSize.width, labelSize.height)
        self.attributedText = NSAttributedString(string: labelText, attributes: textAttributes)
    }
    
    func updateLabelColor(color: UIColor) {
        textAttributes[NSForegroundColorAttributeName] = color
        self.attributedText = NSAttributedString(string: self.attributedText.string, attributes: textAttributes)
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim.springBounciness = 10
        anim.springSpeed = 15
        anim.fromValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
        anim.toValue = NSValue(CGPoint: CGPointMake(0.9, 0.9))
        self.layer.pop_addAnimation(anim, forKey: "PopScale")
        super.touchesBegan(touches as Set<NSObject>, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim.springBounciness = 10
        anim.springSpeed = 15
        anim.fromValue = NSValue(CGPoint: CGPointMake(0.9, 0.9))
        anim.toValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
        self.layer.pop_addAnimation(anim, forKey: "PopScaleback")
        super.touchesEnded(touches as Set<NSObject>, withEvent: event)

    }


    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
