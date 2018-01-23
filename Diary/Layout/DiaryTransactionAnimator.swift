//
//  DiaryTransactionAnimator.swift
//  Diary
//
//  Created by zhowkevin on 15/10/5.
//  Copyright © 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryTransactionAnimator: NSObject, UINavigationControllerDelegate {
    
    let animator = DiaryAnimator()
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
        animator.operation = operation
        return animator
    }
}
