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
    
    var newSize: CGSize?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let fromView = fromVC!.view
        let toVC   = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let toView = toVC!.view

        toView?.alpha = 0.0
        
        if (operation ==  UINavigationControllerOperation.pop) {
            toView?.transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
            if let newSize = newSize {
                toView?.frame = CGRect(x: (toView?.frame.origin.x)!, y: (toView?.frame.origin.y)!, width: newSize.width, height: newSize.height)
            }
        }else{
            toView?.transform = CGAffineTransform(scaleX: 0.3,y: 0.3);
        }

        containerView.insertSubview(toView!, aboveSubview: fromView!)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations:
            {
                if (self.operation ==  UINavigationControllerOperation.pop) {
                    fromView?.transform = CGAffineTransform(scaleX: 3.3,y: 3.3)

                }else{
                    toView?.transform = CGAffineTransform(scaleX: 1.0,y: 1.0);
                }

                toView?.alpha = 1.0

            }, completion: { finished in
                 transitionContext.completeTransition(true)
        })
        
    }
    
}
