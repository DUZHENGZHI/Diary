//
//  DiaryBaseCollecitionViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/4/26.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryBaseCollecitionViewController: UICollectionViewController {
    
    var fingerPrintButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadCollectionView", name: "DiaryChangeFont", object: nil)
        
        var mDoubleUpRecognizer = UITapGestureRecognizer(target: self, action: "popBack")
        
        mDoubleUpRecognizer.numberOfTapsRequired = 2
        
        self.collectionView?.addGestureRecognizer(mDoubleUpRecognizer)
        
        fingerPrintButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        fingerPrintButton.frame = CGRect(x: 15, y: 15, width: 20, height: 20)
        fingerPrintButton.setImage(UIImage(named: "Fingerprint"), forState: UIControlState.Normal)
        
//        self.view?.addSubview(fingerPrintButton)
        // Do any additional setup after loading the view.
    }
    
    func popBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func reloadCollectionView() {
        println("reloadData")
        self.collectionView?.reloadData()
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
