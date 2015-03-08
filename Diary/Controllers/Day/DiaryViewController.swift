//
//  DiaryViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/6.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryViewController: UIViewController,UIGestureRecognizerDelegate, UIWebViewDelegate{
    
    var diary:Diary!
    
    var webview: UIWebView!
    
    var saveButton:UIButton!
    
    var deleteButton:UIButton!
    
    var editButton:UIButton!
    
    var buttonsView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        

    
        
        webview = UIWebView(frame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height))

        webview.scrollView.bounces = false
        webview.delegate = self
        webview.backgroundColor = UIColor.whiteColor()

        
        self.view.addSubview(self.webview)
        
        var mDoubleUpRecognizer = UITapGestureRecognizer(target: self, action: "hideDiary")
        mDoubleUpRecognizer.delegate = self
        mDoubleUpRecognizer.numberOfTapsRequired = 2
        self.webview.addGestureRecognizer(mDoubleUpRecognizer)
        
        
        var mTapUpRecognizer = UILongPressGestureRecognizer(target: self, action: "showButtons:")
        mTapUpRecognizer.delegate = self
        mTapUpRecognizer.minimumPressDuration = 0.6
//        mTapUpRecognizer.numberOfTapsRequired = 1
        self.webview.addGestureRecognizer(mTapUpRecognizer)
        //Add buttons
        
        buttonsView = UIView(frame: CGRectMake(0, screenRect.height, screenRect.width, 80.0))
        buttonsView.backgroundColor = UIColor.whiteColor()
        buttonsView.alpha = 0.0
        
        saveButton = diaryButtonWith(text: "存",  fontSize: 18.0,  width: 36.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        saveButton.center = CGPointMake(buttonsView.frame.width/2.0, buttonsView.frame.height/2.0)
        
        saveButton.addTarget(self, action: "saveToRoll", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonsView.addSubview(saveButton)
        
        
        editButton = diaryButtonWith(text: "改",  fontSize: 18.0,  width: 36.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        editButton.center = CGPointMake(saveButton.center.x - 56.0, saveButton.center.y)
        
        editButton.addTarget(self, action: "editDiary", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonsView.addSubview(editButton)
        
        deleteButton = diaryButtonWith(text: "删",  fontSize: 18.0,  width: 36.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        deleteButton.center = CGPointMake(saveButton.center.x + 56.0, saveButton.center.y)
        
        deleteButton.addTarget(self, action: "deleteThisDiary", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonsView.addSubview(deleteButton)
        
        self.view.addSubview(buttonsView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var timeString = "\(numberToChinese(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: NSDate.new())))年 \(numberToChinese(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate.new())))月 \(numberToChinese(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitDay, fromDate: NSDate.new())))日"
        
        
        //WebView method
        
        var newDiaryString = diary.content.stringByReplacingOccurrencesOfString("\n", withString: "<br>", options: NSStringCompareOptions.LiteralSearch, range: nil)
        webview.loadHTMLString("<!DOCTYPE html><html><meta charset='utf-8'><head><title></title><style>body{padding:20px 0 20px 20px;} * {-webkit-text-size-adjust: 100%; margin:0; font-family: 'Wyue-GutiFangsong-NC'; -webkit-writing-mode: vertical-rl; letter-spacing: 3px;} .content { min-width: \(self.view.frame.size.width - 120)px; margin-right: 10px;} .content p{ font-size: 14pt; line-height: 28pt;} .extra{ font-size:12pt; line-height: 15pt; margin-right:50px;}</style></head><body><div class='content'><p>\(newDiaryString)</p></div><div class='extra'>\(diary.location)<br>\(timeString)</div></body></html>", baseURL: nil)
    }
    
    func showButtons(sender: UILongPressGestureRecognizer) {

        if(sender.state == UIGestureRecognizerState.Began) {
            
            if(buttonsView.alpha == 0.0) {
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                    {
                        self.buttonsView.center = CGPointMake(self.buttonsView.center.x, screenRect.height - self.buttonsView.frame.size.height/2.0)
                        self.buttonsView.alpha = 1.0
                        
                    }, completion: nil)
                
            }else{
                
                UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                    {
                        self.buttonsView.center = CGPointMake(self.buttonsView.center.x, screenRect.height + self.buttonsView.frame.size.height/2.0)
                        self.buttonsView.alpha = 0.0
                    }, completion: nil)
                
            }

        }
    }
    
    func editDiary() {
        var composeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryComposeViewController") as! DiaryComposeViewController
        
        if (diary != nil){
            println("Find \(diary?.created_at)")
            composeViewController.diary = diary
        }
        
        self.presentViewController(composeViewController, animated: true, completion: nil)

    }
    
    func saveToRoll() {
        webview.captureView()
    }
    
    
    func deleteThisDiary() {
        managedContext.deleteObject(diary)
        hideDiary()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webview.scrollView.contentOffset = CGPointMake(webview.scrollView.contentSize.width - webview.frame.size.width, 0)
    }
    
    func hideDiary() {

        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer.isKindOfClass(UILongPressGestureRecognizer)){
            if((otherGestureRecognizer as! UILongPressGestureRecognizer).minimumPressDuration == 0.6){
                return false
            }else{
                return true
            }
            
        }
        return true
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
