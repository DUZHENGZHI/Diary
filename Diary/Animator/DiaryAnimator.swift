//
//  DiaryAnimator.swift
//  Diary
//
//  Created by kevinzhow on 15/2/18.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var fromView: UIView!
    var transitionContext: UIViewControllerContextTransitioning!
    
    var pop:Bool = false

    override init() {
        
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        var inview = transitionContext.containerView()
        var fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        var fromView = fromVC!.view
        var toVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        var toView = toVC!.view
        var initialRect = CGRectMake(fromVC!.view.frame.size.width/2.0, fromVC!.view.frame.size.height/2.0, 0, 0)
        
        var finalRect  = transitionContext.finalFrameForViewController(toVC!)
        

        toView.alpha = 0.0
        
        if (pop) {
            toView.transform = CGAffineTransformMakeScale(1.0,1.0)
        }else{
            toView.transform = CGAffineTransformMakeScale(0.3,0.3);
        }

        inview.insertSubview(toView, aboveSubview: fromView)

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations:
            {
                if (self.pop) {
                    fromView.transform = CGAffineTransformMakeScale(3.3,3.3)
                }else{
                    toView.transform = CGAffineTransformMakeScale(1,1);
                }
                
                toView.alpha = 1.0

            }, completion: { finished in
                 transitionContext.completeTransition(true)
        })
        
    }
    
}
