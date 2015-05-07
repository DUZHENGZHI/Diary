//
//  DiaryProgress.swift
//  Diary
//
//  Created by kevinzhow on 15/3/12.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryProgress: UIView {
    
    var progressPoint:CAShapeLayer!
    var progressPointColor:UIColor = DiaryRed
    var progress:CGFloat! = 0{
        didSet {
            
            if (self.frame.size.width*progress >= 0 && self.frame.size.width*progress <= self.frame.size.width) {
                progressPoint.position = CGPointMake(self.frame.size.width*progress, self.frame.size.height/2.0)
            }

        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgress()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProgress()
    }
    
    func setupProgress() {
        self.layer.cornerRadius = self.frame.size.height/2.0
        self.backgroundColor = UIColor(white: 0.97, alpha: 0.4)
        progressPoint = CAShapeLayer()
        progressPoint.frame = CGRectMake(0, 0, self.frame.size.height * 4, 2)
//        progressPoint.cornerRadius = progressPoint.frame.size.height/2.0
        progressPoint.backgroundColor = progressPointColor.CGColor
        progressPoint.position = CGPointMake(0, self.frame.size.height/2.0)
        self.layer.addSublayer(progressPoint)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
