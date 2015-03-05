//
//  DiaryComposeViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/4.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData



class DiaryComposeViewController: UIViewController ,UITextViewDelegate, NSLayoutManagerDelegate{
    
    var composeView:UITextView!
    var storage:NSTextStorage!
    var keyboardSize:CGSize!
    var finishButton:UIButton!
    
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

        composeView = UITextView(frame: CGRectMake(0, 0, screenRect.width, screenRect.height), textContainer: container)
        composeView.font = DiaryFont
        composeView.editable = true
        composeView.userInteractionEnabled = true
        composeView.delegate = self
        composeView.textContainerInset = UIEdgeInsetsMake(20, 20, 50, 20)
//        composeView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)((90.0) / 180.0 * M_PI))
        composeView.becomeFirstResponder()
        self.view.addSubview(composeView)
        
        //Add finish button
        
        finishButton = diaryButtonWith(text: "终",  fontSize: 18.0,  width: 36.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        finishButton.center = CGPointMake(screenRect.width - 30, screenRect.height - 30)
        
        finishButton.addTarget(self, action: "finishCompose:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(finishButton)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "preferredContentSizeChanged:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    func finishCompose(button: UIButton) {
        print("Finish compose \n")
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entityForName("Diary", inManagedObjectContext: managedContext)
        
        let diary = Diary(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //3
        diary.content = composeView.text
        diary.location = "广州 珠江畔"
        diary.updateTimeWithDate(NSDate.new())        
        //4
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func textViewDidChange(textView: UITextView) {
        if (keyboardSize != nil){
            updateTextViewSizeForKeyboardHeight(keyboardSize.height)
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTextViewSizeForKeyboardHeight(keyboardHeight: CGFloat) {
        composeView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardHeight)
        
        finishButton.center = CGPointMake(screenRect.width - finishButton.frame.size.height/2.0 - 20, screenRect.height - keyboardSize.height - finishButton.frame.size.height/2.0 - 50)
        

    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let rectValue = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            keyboardSize = rectValue.CGRectValue().size
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
