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
    var locationTextView:UITextView!
    var storage:NSTextStorage!
    var keyboardSize:CGSize = CGSizeMake(0, 0)
    var finishButton:UIButton!
    var diary:Diary?
    var locationHelper: DiaryLocationHelper = DiaryLocationHelper.new()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storage = DiaryTextStorage()

        let containerSize = CGSize(width: screenRect.width, height: CGFloat.max)
        let container = NSTextContainer(size: containerSize)

        container.widthTracksTextView = true
        let layoutManager = NSLayoutManager()
        layoutManager.delegate = self


        storage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(container)

        composeView = UITextView(frame: CGRectMake(0, 0, screenRect.width, screenRect.height), textContainer: container)
        composeView.font = DiaryFont
        composeView.editable = true
        composeView.userInteractionEnabled = true
        composeView.delegate = self
        composeView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20)
        
        //Add LocationTextView
        locationTextView = UITextView(frame: CGRectMake(0, composeView.frame.size.height - 30.0, screenRect.width, 30.0))
        locationTextView.font = DiaryLocationFont
        locationTextView.editable = true
        locationTextView.userInteractionEnabled = true
        locationTextView.alpha = 0.0
        locationTextView.bounces = false
        
        if(diary != nil){
            composeView.text = diary?.content
            self.composeView.contentOffset = CGPointMake(0, self.composeView.contentSize.height)
            locationTextView.text = diary?.location
        }
//        composeView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)((90.0) / 180.0 * M_PI))
        composeView.becomeFirstResponder()
        self.view.addSubview(composeView)
        

//        composeView.textContainerInset = UIEdgeInsetsMake(20, 20, 50, 20)
        self.view.addSubview(locationTextView)
        
        
        //Add finish button
        
        finishButton = diaryButtonWith(text: "完",  fontSize: 18.0,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        finishButton.center = CGPointMake(screenRect.width - 20, screenRect.height - 30)
        
        finishButton.addTarget(self, action: "finishCompose:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(finishButton)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAddress:", name: "DiaryLocationUpdated", object: nil)

        // Do any additional setup after loading the view.
    }
    
    func updateAddress(notification:NSNotification) {
        var address = notification.object as! String
        println("Author at \(address)")
        if (diary?.location == "" || diary?.location == nil){
            locationTextView.text = "于 \(address)"
        }else{
            locationTextView.text = diary?.location
        }

        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.locationTextView.alpha = 1.0

            }, completion: nil)
        locationHelper.locationManager.stopUpdatingLocation()
    }
    
    func finishCompose(button: UIButton) {
        print("Finish compose \n")
        self.composeView.endEditing(true)
        self.locationTextView.endEditing(true)
        if (composeView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 1){
            
            if(diary == nil) {
                let entity =  NSEntityDescription.entityForName("Diary", inManagedObjectContext: managedContext)
                
                let newdiary = Diary(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                newdiary.content = composeView.text
                if (locationHelper.address != nil){
                    newdiary.location = locationTextView.text
                }else{
                    newdiary.location = ""
                }
                
                newdiary.updateTimeWithDate(NSDate.new())
            }else{
                diary!.content = composeView.text
                if (locationHelper.address != nil){
                    if (locationHelper.address != nil){
                        diary!.location = locationTextView.text
                    }
                }else{
                    diary!.location = ""
                }
                diary!.updateTimeWithDate(NSDate.new())
            }

            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func textViewDidChange(textView: UITextView) {
        updateTextViewSizeForKeyboardHeight(keyboardSize.height)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTextViewSizeForKeyboardHeight(keyboardHeight: CGFloat) {
        
        var newKeyboardHeight = keyboardHeight
        
        UIView.animateWithDuration(1.0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                if (self.locationTextView.text == nil) {
                    self.composeView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - newKeyboardHeight)
                }else{
                    self.composeView.frame = CGRectMake(0, 0, self.composeView.frame.size.width,  self.view.frame.height - newKeyboardHeight - 40.0 - self.finishButton.frame.size.height/2.0)
                }

//                self.locationTextView.frame = CGRectMake(20, self.composeView.frame.size.height - 30.0, self.composeView.frame.size.width - 20, 30.0)
                
                self.finishButton.center = CGPointMake(self.view.frame.width - self.finishButton.frame.size.height/2.0 - 10, self.view.frame.height - newKeyboardHeight - self.finishButton.frame.size.height/2.0 - 10)
                
                self.locationTextView.center = CGPointMake(self.locationTextView.frame.size.width/2.0 + 20.0, self.finishButton.center.y)
                
            }, completion: nil)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
        if let rectValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
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
