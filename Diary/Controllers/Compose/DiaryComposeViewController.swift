//
//  DiaryComposeViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/4.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit




class DiaryComposeViewController: UIViewController ,UITextViewDelegate{
    
    var composeView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = NSTextStorage()

        let containerSize = CGSize(width: screenRect.width, height: CGFloat.max)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        let layoutManager = NSLayoutManager()

        storage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(container)
        let font = UIFont(name: "Wyue-GutiFangsong-NC", size: 16.0) as UIFont!
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        var textAttributes: [NSObject : AnyObject]! = [NSFontAttributeName: font, NSVerticalGlyphFormAttributeName: 1, NSParagraphStyleAttributeName: paragraphStyle]
        

        storage.appendAttributedString(NSAttributedString(string: "asdasdsad我主动奥", attributes: textAttributes))
        
        composeView = UITextView(frame: CGRectMake(0, 0, screenRect.width, 300), textContainer: container)

        composeView.editable = true
        composeView.userInteractionEnabled = true
        composeView.delegate = self

        self.view.addSubview(composeView)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }

    override func viewDidLayoutSubviews() {

        composeView.frame = view.bounds
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
