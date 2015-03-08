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
    
    var textInt: Int = 0
    
    override func awakeFromNib() {
        
        self.textLabel = DiaryLabel(fontname: "Wyue-GutiFangsong-NC", labelText: labelText, fontSize: 16.0, lineHeight: 5.0)

        
        self.addSubview(textLabel)
    }
    
    override func layoutSubviews() {
        
        self.textLabel.center = CGPointMake(itemWidth/2.0, self.textLabel.frame.size.height/2.0 + self.textLabel.font.pointSize)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim.springBounciness = 10
        anim.springSpeed = 15
        anim.fromValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
        anim.toValue = NSValue(CGPoint: CGPointMake(0.9, 0.9))
        self.layer.pop_addAnimation(anim, forKey: "PopScale")
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim.springBounciness = 10
        anim.springSpeed = 15
        anim.fromValue = NSValue(CGPoint: CGPointMake(0.9, 0.9))
        anim.toValue = NSValue(CGPoint: CGPointMake(1.0, 1.0))
        self.layer.pop_addAnimation(anim, forKey: "PopScaleback")
        super.touchesEnded(touches, withEvent: event)
    }

}
