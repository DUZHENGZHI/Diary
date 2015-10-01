//
//  DiaryViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/6.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import MonkeyKing

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
        
        let mDoubleUpRecognizer = UITapGestureRecognizer(target: self, action: "hideDiary")
        mDoubleUpRecognizer.delegate = self
        mDoubleUpRecognizer.numberOfTapsRequired = 2
        self.webview.addGestureRecognizer(mDoubleUpRecognizer)
        
        
        let mTapUpRecognizer = UITapGestureRecognizer(target: self, action: "showButtons")
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
        
        deleteButton = diaryButtonWith(text: "刪",  fontSize: buttonFontSize,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        deleteButton.center = CGPointMake(saveButton.center.x + 56.0, saveButton.center.y)
        
        deleteButton.addTarget(self, action: "deleteThisDiary", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonsView.addSubview(deleteButton)
        
        self.view.addSubview(buttonsView)
        
        webview.alpha = 0.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadWebView", name: "DiaryChangeFont", object: nil)
        
        showTut()
        

    }
    
    func showTut() {
        
        if tutShowed {
            
        }else {
            tutShowed = true
            let newView = getTutView()
            self.view.addSubview(newView)
            
            UIView.animateWithDuration(1.0, delay: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    newView.alpha = 0

                }, completion: { finish in
                    newView.removeFromSuperview()
            })
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadWebView()
    }
    
    func reloadWebView() {
        
        let timeString = "\(numberToChinese(NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: diary.created_at)))年 \(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: diary.created_at)))月 \(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: diary.created_at)))日"
        
        //WebView method
        
        let newDiaryString = diary.content.stringByReplacingOccurrencesOfString("\n", withString: "<br>", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var title = ""
        var contentWidthOffset = 140
        var contentMargin:CGFloat = 10
        
        if defaultFont == secondFont {
            contentWidthOffset = 115
            contentMargin = 20
        }
        
        if let titleStr = diary?.title {
            let parsedTime = "\(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: diary.created_at))) 日"
            if titleStr != parsedTime {
                title = titleStr
                contentWidthOffset = 205
                contentMargin = 10
                title = "<div class='title'>\(title)</div>"
            }else{
                
                if defaultFont == secondFont {
                    contentWidthOffset+=15
                }
                
            }
        }
        
        var minWidth = self.view.frame.size.width - CGFloat(contentWidthOffset)
        
        let fontStr = defaultFont
        let coverImage = ""
        
        let bodyPadding = 0
        
        let containerCSS = " padding:25px 10px 25px 25px; "
        
//        if let coverURL = diary.coverCloudKey {
//            bodyPadding = 35
//            containerCSS = " padding: 0px 0px 0px 0px; "
//            coverImage = "<div class='cover'><img src='\(coverURL).jpg'></div>"
//        }
        
        var titleMarginRight:CGFloat = 15
        
        if defaultFont == secondFont {
            minWidth = minWidth - 10.0
            titleMarginRight = 25
        }
        
        let headertags = "<!DOCTYPE html><html><meta charset='utf-8'><head><title></title><style>"
        let bodyCSS = "body{padding:\(bodyPadding)px;} "
        let allCSS = "* {-webkit-text-size-adjust: 100%; margin:0; font-family: '\(fontStr)'; -webkit-writing-mode: vertical-rl; letter-spacing: 3px;}"
        let contentCSS = ".content { min-width: \(minWidth)px; margin-right: \(contentMargin)px;} .content p{ font-size: 12pt; line-height: 24pt;}"
        let titleCSS = ".title {font-size: 12pt; font-weight:bold; line-height: 24pt; margin-right: \(titleMarginRight)px; padding-left: 20px;} "
        let extraCSS = ".extra{ font-size:12pt; line-height: 24pt; margin-right:30px; }"
        let stampCSS = ".stamp {width:24px; height:auto; position:fixed; bottom:20px;}"
        let coverCSS = ".cover {position: relative; width: 224px; overflow:hidden;} .cover img {height:100%; width:auto; position: absolute; top: -9999px; bottom: -9999px; left: -9999px; right: -9999px; margin: auto;} "
        
        var extraHTML = "<div class='extra'><br>\(timeString) </div>"
        
        if let location = diary.location {
            extraHTML = "<div class='extra'>\(location)<br>\(timeString) </div>"
        }
        
        let contentHTML = "<div class='container'>\(title)<div class='content'><p>\(newDiaryString)</p></div>"
        
        webview.loadHTMLString("\(headertags)\(bodyCSS) \(allCSS) \(contentCSS) \(titleCSS) \(extraCSS) .container { \(containerCSS) } \(stampCSS) \(coverCSS) </style></head> <body>\(coverImage) \(contentHTML) \(extraHTML)</body></html>", baseURL: nil)
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
        let composeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryComposeViewController") as! DiaryComposeViewController
        
        if let diary = diary {
            
            print("Find \(diary.created_at)")
            
            composeViewController.diary = diary
        }
        
        self.presentViewController(composeViewController, animated: true, completion: nil)
    }
    
    func saveToRoll() {
        
        let offset = self.webview.scrollView.contentOffset.x
        
        let image =  webview.captureView()
        
//        image = image.drawImage(UIImage(named: "Fingerprint")!, frame: CGRect(x: image.size.width/2.0 - 25.0, y: image.size.height - 75.0, width: 50.0, height: 50.0))
        
        self.webview.scrollView.contentOffset.x = offset

        var sharingItems = [AnyObject]()
        sharingItems.append(image)
        let info = MonkeyKing.Info(
            title: nil,
            description: nil,
            thumbnail: nil,
            media: .Image(image)
        )
        
        let sessionMessage = MonkeyKing.Message.WeChat(.Session(info: info))
        
        let weChatSessionActivity = WeChatActivity(
            type: .Session,
            message: sessionMessage,
            finish: { success in
                print("share Image to WeChat Session success: \(success)")
            }
        )
        
        let timelineMessage = MonkeyKing.Message.WeChat(.Timeline(info: info))
        
        let weChatTimelineActivity = WeChatActivity(
            type: .Timeline,
            message: timelineMessage,
            finish: { success in
                print("share Image to WeChat Timeline success: \(success)")
            }
        )
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: [weChatSessionActivity, weChatTimelineActivity])
        activityViewController.popoverPresentationController?.sourceView = self.saveButton
        self.presentViewController(activityViewController, animated: true, completion: nil)

    }
    
    
    func deleteThisDiary() {
        managedContext.deleteObject(diary)
        if let DiaryID = diary.id {
            
            fetchCloudRecordWithID(DiaryID, complete: { (record) -> Void in
                if let record = record {
                    privateDB.deleteRecordWithID(record.recordID, completionHandler: { (recordID, error) -> Void in
                        if let error = error {
                            print("\(error.description)")
                        } else {
                            print("delete \(recordID)")
                        }
                    })
                }
            })
        }
        do {
            try managedContext.save()
        } catch _ {
        }
        hideDiary()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIView.animateWithDuration(1.0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
        {
            self.webview.alpha = 1.0
        }, completion: nil)

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
