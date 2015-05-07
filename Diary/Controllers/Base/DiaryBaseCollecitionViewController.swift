//
//  DiaryBaseCollecitionViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/4/26.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryBaseCollecitionViewController: UIViewController {
    
    var collectionView: UICollectionView = UICollectionView(frame: screenRect, collectionViewLayout: DiaryLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadCollectionView", name: "DiaryChangeFont", object: nil)
        
        let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
        pan.delegate = self
//        self.view.addGestureRecognizer(pan)
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.frame = screenRect
        // Do any additional setup after loading the view.
    }
    
    func reloadCollectionView() {
        println("reloadData")
        self.collectionView.reloadData()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake {
            println("Device Shaked")
            showAlert()
        }
    }
    
    func showAlert() {
        var alert = UIAlertController(title: "设置", message: "希望切换字体吗", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "算啦", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "好的", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                toggleFont()
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
    }
}



extension DiaryBaseCollecitionViewController: UIGestureRecognizerDelegate, UICollectionViewDelegate {
    
    func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view{
            
            collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x + translation.x, y: collectionView.contentOffset.y), animated: false)

        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
}
