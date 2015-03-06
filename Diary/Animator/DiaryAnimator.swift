//
//  DiaryAnimator.swift
//  Diary
//
//  Created by kevinzhow on 15/2/18.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var fromCollectionView: UICollectionView!
    var transitionLayout: UICollectionViewTransitionLayout!
    var startTime: NSTimeInterval = 0.0
    var endTime: NSTimeInterval = 0.0
    var timer:NSTimer!
    var transitionContext: UIViewControllerContextTransitioning!
    var toCollectionView: UICollectionView!

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
        
        toView.alpha = 0.0
        
        var initialRect = CGRectMake(fromVC!.view.frame.size.width/2.0, fromVC!.view.frame.size.height/2.0, 0, 0)
        
        //inview.window?.convertRect(fromCollectionView!.frame, fromView: fromCollectionView?.superview)
        
        var finalRect  = transitionContext.finalFrameForViewController(toVC!)
        
//        var toLayout = toCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
//        
//        var currentLayout = fromCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
//        var currentLayoutCopy = UICollectionViewFlowLayout.new()
//        
//        currentLayoutCopy.itemSize = currentLayout.itemSize
//        currentLayoutCopy.sectionInset = currentLayout.sectionInset
//        currentLayoutCopy.minimumLineSpacing = currentLayout.minimumLineSpacing
//        currentLayoutCopy.minimumInteritemSpacing = currentLayout.minimumInteritemSpacing
//        currentLayoutCopy.scrollDirection = currentLayout.scrollDirection
//        
//        self.fromCollectionView?.setCollectionViewLayout(currentLayoutCopy, animated: false)
        
//        var contentInset = toCollectionView.contentInset
        
//        var oldBottomInset = contentInset.bottom
//        contentInset.bottom = CGRectGetHeight(finalRect)-(toLayout.itemSize.height+toLayout.sectionInset.bottom+toLayout.sectionInset.top)
//        
//        self.toCollectionView.contentInset = contentInset;
//        self.toCollectionView.setCollectionViewLayout(currentLayout, animated: false)
//        toView.frame = initialRect
        toView.transform = CGAffineTransformMakeScale(0.3,0.3);

        inview.insertSubview(toView, aboveSubview: fromView)

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations:
            {
//                toView.frame = finalRect
                toView.transform = CGAffineTransformMakeScale(1,1);
                toView.alpha = 1.0
//                self.toCollectionView.performBatchUpdates({
//                    self.toCollectionView.setCollectionViewLayout(toLayout, animated: false)
//                }, completion: { finished in
//                    
//                    self.toCollectionView.contentInset = UIEdgeInsetsMake(contentInset.top,
//                        contentInset.left,
//                        oldBottomInset,
//                        contentInset.right)
//                })
            
            }, completion: { finished in
                 transitionContext.completeTransition(true)
        })
        
    }
    
}
