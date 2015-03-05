//
//  DiaryComposeViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/4.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit




class DiaryComposeViewController: UIViewController ,UITextViewDelegate, NSLayoutManagerDelegate{
    
    var composeView:UITextView!
    var storage:NSTextStorage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storage = DiaryTextStorage()

        let containerSize = CGSize(width: screenRect.width, height: CGFloat.max)
        let container = NSTextContainer(size: containerSize)

        container.widthTracksTextView = true
        let layoutManager = DiaryVerticalTextLayout()
        layoutManager.delegate = self


        storage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(container)

        composeView = UITextView(frame: CGRectMake(0, 0, screenRect.width, 300), textContainer: container)
        composeView.font = DiaryFont
        composeView.editable = true
        composeView.userInteractionEnabled = true
        composeView.delegate = self
        composeView.textContainerInset = UIEdgeInsetsMake(20, 20, 50, 20)
//        composeView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)((90.0) / 180.0 * M_PI))
        composeView.becomeFirstResponder()
        self.view.addSubview(composeView)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {

        composeView.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.height)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTextViewSizeForKeyboardHeight(keyboardHeight: CGFloat) {
        composeView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardHeight)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let rectValue = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardSize = rectValue.CGRectValue().size
            updateTextViewSizeForKeyboardHeight(keyboardSize.height)
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        updateTextViewSizeForKeyboardHeight(0)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
