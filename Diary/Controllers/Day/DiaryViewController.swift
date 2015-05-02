//
//  DiaryViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/6.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryViewController: DiaryBaseViewController,UIGestureRecognizerDelegate, UIWebViewDelegate, UIScrollViewDelegate{
    
    var diary:Diary!
    
    var webview: UIWebView!
    
    var saveButton:UIButton!
    
    var deleteButton:UIButton!
    
    var editButton:UIButton!
    
    var buttonsView:UIView!
    
    var pullView: DiaryPullView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        setupUI()
        
        showButtons()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        webview = UIWebView(frame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height))
        
        webview.scrollView.bounces = true
        
        webview.delegate = self
        webview.backgroundColor = UIColor.whiteColor()
        webview.scrollView.delegate = self
        
        self.view.addSubview(self.webview)
        
        pullView = DiaryPullView(frame: CGRectMake(0, 0, 30.0, 30.0))
        pullView.center = CGPoint(x: screenRect.width/2.0, y: pullView.frame.size.height/2.0)
        
        self.view.addSubview(pullView)
        
        var mDoubleUpRecognizer = UITapGestureRecognizer(target: self, action: "hideDiary")
        mDoubleUpRecognizer.delegate = self
        mDoubleUpRecognizer.numberOfTapsRequired = 2
        self.webview.addGestureRecognizer(mDoubleUpRecognizer)
        
        
        var mTapUpRecognizer = UITapGestureRecognizer(target: self, action: "showButtons")
        mTapUpRecognizer.delegate = self
        mTapUpRecognizer.numberOfTapsRequired = 1
        self.webview.addGestureRecognizer(mTapUpRecognizer)
        mTapUpRecognizer.requireGestureRecognizerToFail(mDoubleUpRecognizer)
        //Add buttons
        
        buttonsView = UIView(frame: CGRectMake(0, screenRect.height, screenRect.width, 80.0))
        buttonsView.backgroundColor = UIColor.clearColor()
        buttonsView.alpha = 0.0
        
        var buttonFontSize:CGFloat = 18.0
        
        if defaultFont == secondFont {
            buttonFontSize = 16.0
        }
        
        saveButton = diaryButtonWith(text: "存",  fontSize: buttonFontSize,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        saveButton.center = CGPointMake(buttonsView.frame.width/2.0, buttonsView.frame.height/2.0)
        
        saveButton.addTarget(self, action: "saveToRoll", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonsView.addSubview(saveButton)
        
        
        editButton = diaryButtonWith(text: "改",  fontSize: buttonFontSize,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        editButton.center = CGPointMake(saveButton.center.x - 56.0, saveButton.center.y)
        
        editButton.addTarget(self, action: "editDiary", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonsView.addSubview(editButton)
        
        deleteButton = diaryButtonWith(text: "删",  fontSize: buttonFontSize,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        deleteButton.center = CGPointMake(saveButton.center.x + 56.0, saveButton.center.y)
        
        deleteButton.addTarget(self, action: "deleteThisDiary", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonsView.addSubview(deleteButton)
        
        self.view.addSubview(buttonsView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadWebView", name: "DiaryChangeFont", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadWebView()
 
    }
    
    func reloadWebView() {
        var timeString = "\(numberToChinese(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: diary.created_at)))年 \(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: diary.created_at)))月 \(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitDay, fromDate: diary.created_at)))日"
        
        //WebView method
        
        var newDiaryString = diary.content.stringByReplacingOccurrencesOfString("\n", withString: "<br>", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var title = ""
        var contentWidthOffset = 120
        var contentMargin:CGFloat = 10
        
        if defaultFont == secondFont {
            contentWidthOffset = 110
            contentMargin = 20
        }
        
        if let titleStr = diary?.title {
            var parsedTime = "\(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitDay, fromDate: diary.created_at))) 日"
            if titleStr != parsedTime {
                title = titleStr
                contentWidthOffset = 175
                contentMargin = 10
                title = "<div class='title'>\(title)</div>"
            }else{
                
                if defaultFont == secondFont {
                    contentWidthOffset+=15
                }
                
            }
        }
        
        var stampPath = NSURL(fileURLWithPath: baseCoverURL())
        var minWidth = self.view.frame.size.width - CGFloat(contentWidthOffset)
        
        var fontStr = defaultFont
        var coverImage = ""
        
        if let coverURL = diary.coverCloudKey {
            coverImage = "<div class='cover'><img src='\(coverURL).jpg'></div>"
        }
        
        var titleMarginRight:CGFloat = 15
        
        if defaultFont == secondFont {
            minWidth = minWidth - 10.0
            titleMarginRight = 25
        }
        
        webview.loadHTMLString("<!DOCTYPE html><html><meta charset='utf-8'><head><title></title><style>body{padding:0px;} * {-webkit-text-size-adjust: 100%; margin:0; font-family: '\(fontStr)'; -webkit-writing-mode: vertical-rl; letter-spacing: 3px;} .content { min-width: \(minWidth)px; margin-right: \(contentMargin)px;} .content p{ font-size: 14pt; line-height: 28pt;} .title {font-size: 18pt; line-height: 28pt; font-weight:bold; margin-right: \(titleMarginRight)px;} .extra{ font-size:12pt; line-height: 20pt; margin-right:30px; } .container {padding:25px 10px 25px 25px;} .stamp {width:24px; height:auto; position:fixed; bottom:20px;} .cover {width: 280px; overflow:hidden;} .cover img {height:100%; width:auto;} </style></head><body>\(coverImage)<div class='container'>\(title)<div class='content'><p>\(newDiaryString)</p></div><div class='extra'>\(diary.location)<br>\(timeString) </div></body></html>", baseURL: stampPath)
    }
    
    func showButtons() {

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
    
    func editDiary() {
        var composeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryComposeViewController") as! DiaryComposeViewController
        
        if let diary = diary {
            
            println("Find \(diary.created_at)")
            
            composeViewController.diary = diary
        }
        
        self.presentViewController(composeViewController, animated: true, completion: nil)

    }
    
    func saveToRoll() {
        
        let offset = self.webview.scrollView.contentOffset.x
        
//        webview.layer.borderColor = UIColor(white: 0.0, alpha: 0.3).CGColor
//        webview.layer.borderWidth = 1.0
        
        var image =  webview.captureView()
        
//        webview.layer.borderColor = UIColor.clearColor().CGColor
//        webview.layer.borderWidth = 0.0
        
        self.webview.scrollView.contentOffset.x = offset

        var sharingItems = [AnyObject]()
        sharingItems.append(image)
        println("Do Share")
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.saveButton
        self.presentViewController(activityViewController, animated: true, completion: nil)

    }
    
    
    func deleteThisDiary() {
        managedContext.deleteObject(diary)
        managedContext.save(nil)
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
        
        return true
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y < -80){
            hideDiary()
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pullView.alpha = (-scrollView.contentOffset.y/100.0)
        pullView.center = CGPointMake(self.view.center.x, -scrollView.contentOffset.y - 20)
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
