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
    
    @IBOutlet weak var webview: UIWebView!
    var diary:Diary!
    
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
        
        let mainHTML = NSBundle.mainBundle().URLForResource("DiaryTemplate", withExtension:"html")
        var contents: NSString = ""
        
        do {
            contents = try NSString(contentsOfFile: mainHTML!.path!, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print(error)
        }

        
        let timeString = "\(numberToChinese(NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: diary.created_at)))年 \(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: diary.created_at)))月 \(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: diary.created_at)))日"
        
        contents = contents.stringByReplacingOccurrencesOfString("#timeString#", withString: timeString)
        
        //WebView method
        
        let newDiaryString = diary.content.stringByReplacingOccurrencesOfString("\n", withString: "<br>", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        contents = contents.stringByReplacingOccurrencesOfString("#newDiaryString#", withString: newDiaryString)
        
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
        
        contents = contents.stringByReplacingOccurrencesOfString("#contentMargin#", withString: "\(contentMargin)")
        
        contents = contents.stringByReplacingOccurrencesOfString("#title#", withString: title)
        
        var minWidth = self.view.frame.size.width - CGFloat(contentWidthOffset)
        
        contents = contents.stringByReplacingOccurrencesOfString("#minWidth#", withString: "\(minWidth)")
        
        let fontStr = defaultFont
        
        contents = contents.stringByReplacingOccurrencesOfString("#fontStr#", withString: fontStr)
        
        var titleMarginRight:CGFloat = 15
        
        if defaultFont == secondFont {
            minWidth = minWidth - 10.0
            titleMarginRight = 25
        }
        
        contents = contents.stringByReplacingOccurrencesOfString("#titleMarginRight#", withString: "\(titleMarginRight)")
        
        if let location = diary.location {
            contents = contents.stringByReplacingOccurrencesOfString("#location#", withString: location)
        } else {
            contents = contents.stringByReplacingOccurrencesOfString("#location#", withString: "")
        }
        
        
        webview.loadHTMLString(contents as String, baseURL: nil)
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
        
        UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
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

}
