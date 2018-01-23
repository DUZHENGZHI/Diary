//
//  DiaryLabel.swift
//  Diary
//
//  Created by kevinzhow on 15/3/4.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import pop

func sizeHeightWithText(labelText: NSString,
    fontSize: CGFloat,
    textAttributes: [NSAttributedStringKey : AnyObject]) -> CGRect {
        
    return labelText.boundingRect(
        with: CGSize(width: fontSize,height: 480),
        options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: textAttributes, context: nil)
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
    
    var textAttributes: [NSAttributedStringKey : AnyObject]!
    
    var labelSize: CGRect?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(fontname:String,
        labelText:String,
        fontSize : CGFloat,
        lineHeight: CGFloat){
            
            self.init(frame: CGRect.zero)
            
        self.isUserInteractionEnabled = true
            
            let font = UIFont(name: fontname,
                size: fontSize) as UIFont!
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight
            
        textAttributes = [NSAttributedStringKey.font: font!,
                NSAttributedStringKey.paragraphStyle: paragraphStyle]
            
        labelSize = sizeHeightWithText(labelText: labelText as NSString, fontSize: fontSize ,textAttributes: textAttributes)
            
            self.attributedText = NSAttributedString(
                string: labelText,
                attributes: textAttributes)
            
        self.lineBreakMode = NSLineBreakMode.byCharWrapping
            
            self.numberOfLines = 0
    }
    
    func config(fontname:String,
        labelText:String,
        fontSize : CGFloat,
        lineHeight: CGFloat){
            
        self.isUserInteractionEnabled = true
            
            let font = UIFont(name: fontname,
                size: fontSize) as UIFont!
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight
            
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            paragraphStyle.paragraphSpacing = 0
            
            paragraphStyle.paragraphSpacingBefore = 0
        
        textAttributes = [NSAttributedStringKey.font: font!,
                          NSAttributedStringKey.paragraphStyle: paragraphStyle]
            
        labelSize = sizeHeightWithText(labelText: labelText as NSString, fontSize: fontSize ,textAttributes: textAttributes)
            
            self.attributedText = NSAttributedString(
                string: labelText,
                attributes: textAttributes)
            
            self.numberOfLines = 0
    }
    
    func updateText(labelText: String) {

        self.attributedText = NSAttributedString(
            string: labelText,
            attributes: textAttributes)
    }
    
    func updateLabelColor(color: UIColor) {
        
        textAttributes[NSAttributedStringKey.foregroundColor] = color
        
        self.attributedText = NSAttributedString(
            string: self.attributedText!.string,
            attributes: textAttributes)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim?.springBounciness = 10
        anim?.springSpeed = 15
        anim?.fromValue = NSValue(cgPoint: CGPoint(x: 1.0, y: 1.0))
        anim?.toValue = NSValue(cgPoint: CGPoint(x: 0.9, y: 0.9))
        self.layer.pop_add(anim, forKey: "PopScale")
        super.touchesBegan(touches as Set<UITouch>, with: event)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim?.springBounciness = 10
        anim?.springSpeed = 15
        anim?.fromValue = NSValue(cgPoint: CGPoint(x: 0.9,y: 0.9))
        anim?.toValue = NSValue(cgPoint: CGPoint(x: 1.0, y: 1.0))
        self.layer.pop_add(anim, forKey: "PopScaleback")
        super.touchesEnded(touches as Set<UITouch>, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        let anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim?.springBounciness = 10
        anim?.springSpeed = 15
        anim?.fromValue = NSValue(cgPoint: CGPoint(x: 0.9, y: 0.9))
        anim?.toValue = NSValue(cgPoint: CGPoint(x: 1.0,y: 1.0))
        self.layer.pop_add(anim, forKey: "PopScaleback")
        super.touchesCancelled(touches!, with: event)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
