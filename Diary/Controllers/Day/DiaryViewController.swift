//
//  DiaryViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/6.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryViewController: DiaryBaseViewController,UIGestureRecognizerDelegate, UIWebViewDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var webview: UIWebView!
    var diary:Diary!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var buttonsViewToBottom: NSLayoutConstraint!
    
    var pullView: DiaryPullView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setupUI()
        
        showButtons()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        
        webview.scrollView.bounces = true
        webview.delegate = self
        webview.backgroundColor = UIColor.white
        webview.scrollView.delegate = self
        
        self.view.addSubview(self.webview)
        
        pullView = DiaryPullView(frame: CGRect(x:0, y:0, width:30.0, height:30.0))
        pullView.center = CGPoint(x: screenRect().width/2.0, y: pullView.frame.size.height/2.0)
        
        self.view.addSubview(pullView)
        
        let mDoubleUpRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideDiary))
        mDoubleUpRecognizer.delegate = self
        mDoubleUpRecognizer.numberOfTapsRequired = 2
        self.webview.addGestureRecognizer(mDoubleUpRecognizer)
        
        
        let mTapUpRecognizer = UITapGestureRecognizer(target: self, action: #selector(showButtons))
        mTapUpRecognizer.delegate = self
        mTapUpRecognizer.numberOfTapsRequired = 1
        self.webview.addGestureRecognizer(mTapUpRecognizer)
        mTapUpRecognizer.require(toFail: mDoubleUpRecognizer)
        //Add buttons
        
        buttonsView.backgroundColor = UIColor.clear
        buttonsView.alpha = 0.0
        
        let buttonFontSize:CGFloat = 18.0
        
        saveButton.customButtonWith(text: "存",  fontSize: buttonFontSize,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        
        saveButton.addTarget(self, action: #selector(saveToRoll), for: UIControlEvents.touchUpInside)
        
        
        editButton.customButtonWith(text: "改",  fontSize: buttonFontSize,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
    
        
        editButton.addTarget(self, action: #selector(editDiary), for: UIControlEvents.touchUpInside)
    
        
        deleteButton.customButtonWith(text: "删",  fontSize: buttonFontSize,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        
        deleteButton.addTarget(self, action: #selector(deleteThisDiary), for: UIControlEvents.touchUpInside)
    
        
        webview.alpha = 0.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWebView), name: NSNotification.Name(rawValue: "DiaryChange"), object: nil)
        
        showTut()
        
        reloadWebView()
    }
    
    func showTut() {
        
        if tutShowed {
            
        }else {
            tutShowed = true
            let newView = getTutView()
            self.view.addSubview(newView)
            
            UIView.animate(withDuration: 1.0, delay: 1.0, options: [UIViewAnimationOptions.curveEaseInOut], animations:
                {
                    newView.alpha = 0

                }, completion: { finish in
                    newView.removeFromSuperview()
            })
        }
        
    }
    
    @objc func reloadWebView() {
        
        let mainHTML = Bundle.main.url(forResource: "DiaryTemplate", withExtension:"html")
        var contents: NSString = ""
        
        do {
            contents = try NSString(contentsOfFile: mainHTML!.path, encoding: String.Encoding.utf8.rawValue)
        } catch let error as NSError {
            debugPrint(error)
        }
        
        let timeString = "\(numberToChinese(number: NSCalendar.current.component(Calendar.Component.year, from: diary.created_at as Date)))年 \(numberToChineseWithUnit(number: NSCalendar.current.component(Calendar.Component.month, from: diary.created_at as Date)))月 \(numberToChineseWithUnit(number: NSCalendar.current.component(Calendar.Component.day, from: diary.created_at as Date)))日"
        
        contents = contents.replacingOccurrences(of: "#timeString#", with: timeString) as NSString
        
        //WebView method
        
        let newDiaryString = diary.content.replacingOccurrences(of: "\n", with: "<br>", options: NSString.CompareOptions.literal, range: nil)
        
        contents = contents.replacingOccurrences(of: "#newDiaryString#", with: newDiaryString) as NSString
        
        var title = ""
        var contentWidthOffset = 140
        var contentMargin:CGFloat = 10
        
        if let titleStr = diary?.title {
            let parsedTime = "\(numberToChineseWithUnit(number: NSCalendar.current.component(Calendar.Component.day, from: diary.created_at as Date))) 日"
            if titleStr != parsedTime {
                title = titleStr
                contentWidthOffset = 205
                contentMargin = 10
                title = "<div class='title'>\(title)</div>"
            }
        }
        
        contents = contents.replacingOccurrences(of: "#contentMargin#", with: "\(contentMargin)") as NSString
        
        contents = contents.replacingOccurrences(of:"#title#", with: title) as NSString
        
        let minWidth = self.view.frame.size.width - CGFloat(contentWidthOffset)
        
        contents = contents.replacingOccurrences(of:"#minWidth#", with: "\(minWidth)") as NSString
        
        let fontStr = defaultFont
        
        contents = contents.replacingOccurrences(of:"#fontStr#", with: fontStr) as NSString
        
        let titleMarginRight:CGFloat = 15
        
        contents = contents.replacingOccurrences(of:"#titleMarginRight#", with: "\(titleMarginRight)") as NSString
        
        if let location = diary.location {
            contents = contents.replacingOccurrences(of:"#location#", with: location) as NSString
        } else {
            contents = contents.replacingOccurrences(of:"#location#", with: "") as NSString
        }
        
        
        webview.loadHTMLString(contents as String, baseURL: nil)
    }
    
    @objc func showButtons() {

        view.bringSubview(toFront: buttonsView)
        
        if(buttonsView.alpha == 0.0) {
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations:
                { [weak self] in
                    self?.buttonsViewToBottom.constant = 0
                    
                    self?.buttonsView.alpha = 1.0
                    
                    self?.view.layoutIfNeeded()
                    
                }, completion: nil)
            
        }else{
            
            UIView.animate(withDuration: 0.1, delay: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations:
                { [weak self] in
                    self?.buttonsViewToBottom.constant = -100
                    
                    self?.buttonsView.alpha = 0.0
                    
                    self?.view.layoutIfNeeded()
                    
                }, completion: nil)
            
        }
    }
    
    @objc func editDiary() {
        let composeViewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryComposeViewController") as! DiaryComposeViewController
        
        if let diary = diary {
            
            debugPrint("Find \(diary.created_at)")
            
            composeViewController.diary = diary
        }
        
        self.present(composeViewController, animated: true, completion: nil)
    }
    
    @objc func saveToRoll() {
        
        let offset = self.webview.scrollView.contentOffset.x
        
        let image =  webview.captureView()
        
        self.webview.scrollView.contentOffset.x = offset

        var sharingItems = [AnyObject]()
        sharingItems.append(image)
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: [])
        activityViewController.popoverPresentationController?.sourceView = self.saveButton
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    
    @objc func deleteThisDiary() {
        
        DiaryCoreData.sharedInstance.managedContext?.delete(diary)
        
        if let DiaryID = diary.id {
            
            fetchCloudRecordWithID(recordID: DiaryID, complete: { (record) -> Void in
                if let record = record {
                    privateDB.delete(withRecordID: record.recordID, completionHandler: { (recordID, error) -> Void in
                        if let error = error {
                            debugPrint("\(error.localizedDescription)")
                        } else {
                            debugPrint("delete \(String(describing: recordID))")
                        }
                    })
                }
            })
        }
        do {
            try DiaryCoreData.sharedInstance.managedContext?.save()
        } catch _ {
            
        }
        
        hideDiary()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        UIView.animate(withDuration: 0.6, delay: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations:
        {[weak self] in
            self?.webview.alpha = 1.0
        }, completion: nil)

        webview.scrollView.contentOffset = CGPoint(x: webview.scrollView.contentSize.width - webview.frame.size.width, y: 0)
    }
    
    @objc func hideDiary() {

        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y < -80){
            hideDiary()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pullView.alpha = (-scrollView.contentOffset.y/100.0)
        pullView.center = CGPoint(x: self.view.center.x, y:-scrollView.contentOffset.y - 20)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition(in: view, animation: { (content) -> Void in
            
        }) {[weak self] (content) -> Void in
            self?.reloadWebView()
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        print("Diary Deinit")
    }

}
