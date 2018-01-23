//
//  DiaryPopView.swift
//  Diary
//
//  Created by zhowkevin on 15/10/5.
//  Copyright © 2015年 kevinzhow. All rights reserved.
//

import UIKit
import pop

class DiaryPopView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim?.springBounciness = 10
        anim?.springSpeed = 15
        anim?.fromValue = NSValue(cgPoint: CGPoint(x:1.0, y: 1.0))
        anim?.toValue = NSValue(cgPoint: CGPoint(x:0.9,y: 0.9))
        self.layer.pop_add(anim, forKey: "PopScale")
        super.touchesBegan(touches as Set<UITouch>, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim?.springBounciness = 10
        anim?.springSpeed = 15
        anim?.fromValue = NSValue(cgPoint: CGPoint(x:0.9, y:0.9))
        anim?.toValue = NSValue(cgPoint: CGPoint(x:1.0, y:1.0))
        self.layer.pop_add(anim, forKey: "PopScaleback")
        super.touchesEnded(touches as Set<UITouch>, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        let anim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        anim?.springBounciness = 10
        anim?.springSpeed = 15
        anim?.fromValue = NSValue(cgPoint: CGPoint(x:0.9, y:0.9))
        anim?.toValue = NSValue(cgPoint: CGPoint(x:1.0, y:1.0))
        self.layer.pop_add(anim, forKey: "PopScaleback")
        super.touchesCancelled(touches!, withEvent: event)
    }


}
