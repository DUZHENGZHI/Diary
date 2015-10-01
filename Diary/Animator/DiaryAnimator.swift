//
//  DiaryAnimator.swift
//  Diary
//
//  Created by kevinzhow on 15/2/18.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var operation:UINavigationControllerOperation!
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView()
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let fromView = fromVC!.view
        let toVC   = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let toView = toVC!.view

        toView.alpha = 0.0
        
        if (operation ==  UINavigationControllerOperation.Pop) {
            toView.transform = CGAffineTransformMakeScale(1.0,1.0)
        }else{
            toView.transform = CGAffineTransformMakeScale(0.3,0.3);
        }

        containerView!.insertSubview(toView, aboveSubview: fromView)

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                if (self.operation ==  UINavigationControllerOperation.Pop) {
                    fromView.transform = CGAffineTransformMakeScale(3.3,3.3)

                }else{
                    toView.transform = CGAffineTransformMakeScale(1.0,1.0);
                }

                toView.alpha = 1.0

            }, completion: { finished in
                 transitionContext.completeTransition(true)
        })
        
    }
    
}
