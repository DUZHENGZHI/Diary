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
        
        let inview = transitionContext.containerView()
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let fromView = fromVC!.view
        let toVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let toView = toVC!.view
        let initialRect = CGRectMake(fromVC!.view.frame.size.width/2.0, fromVC!.view.frame.size.height/2.0, 0, 0)
        
        let finalRect  = transitionContext.finalFrameForViewController(toVC!)
        

        toView.alpha = 0.0
        
        if (pop) {
            toView.transform = CGAffineTransformMakeScale(1.0,1.0)
        }else{
            toView.transform = CGAffineTransformMakeScale(0.3,0.3);
        }

        inview.insertSubview(toView, aboveSubview: fromView)

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve | UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                if (self.pop) {
                    fromView.transform = CGAffineTransformMakeScale(3.3,3.3)

                }else{
                    toView.transform = CGAffineTransformMakeScale(1.0,1.0);
//                    fromView.transform = CGAffineTransformMakeScale(3.3,3.3);
                }

                toView.alpha = 1.0

            }, completion: { finished in
                 transitionContext.completeTransition(true)
        })
        
    }
    
}
