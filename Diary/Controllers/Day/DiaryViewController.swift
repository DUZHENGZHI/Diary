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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        var timeString = "\(numberToChinese(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: NSDate.new())))年 \(numberToChinese(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate.new())))月 \(numberToChinese(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitDay, fromDate: NSDate.new())))日"

        
        //WebView method
        
        var newDiaryString = diary.content.stringByReplacingOccurrencesOfString("\n", withString: "<br>", options: NSStringCompareOptions.LiteralSearch, range: nil)
    
        
        webview = UIWebView(frame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height))
        webview.loadHTMLString("<!DOCTYPE html><html><meta charset='utf-8'><head><title></title><style>body{padding:20px 0 20px 20px;} * { margin:0; font-family: 'Wyue-GutiFangsong-NC'; -webkit-writing-mode: vertical-rl; letter-spacing: 3px;} .content { min-width: \(self.view.frame.size.width - 120)px; margin-right: 10px;} .content p{ font-size: 14pt; line-height: 28pt;} .extra{ font-size:12pt; line-height: 15pt; margin-right:50px;}</style></head><body><div class='content'><p>\(newDiaryString)</p></div><div class='extra'>\(diary.location)<br>\(timeString)</div></body></html>", baseURL: nil)
        webview.scrollView.bounces = false
        webview.delegate = self

        
        self.view.addSubview(self.webview)
        
        var mSwipeUpRecognizer = UITapGestureRecognizer(target: self, action: "hideDiary")
        mSwipeUpRecognizer.delegate = self
        mSwipeUpRecognizer.numberOfTapsRequired = 2
        self.webview.addGestureRecognizer(mSwipeUpRecognizer)
        // Do any additional setup after loading the view.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webview.scrollView.contentOffset = CGPointMake(webview.scrollView.contentSize.width - webview.frame.size.width, 0)
    }
    
    func hideDiary() {
        println("Hide diary")
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer.isKindOfClass(UILongPressGestureRecognizer)){
            return false
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
