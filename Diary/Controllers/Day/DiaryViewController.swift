//
//  DiaryViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/6.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryViewController: UIViewController {
    
    var diary:Diary!
    
    var textview: DiaryVerticalTextView!
    
    @IBOutlet weak var scrollview: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textview = DiaryVerticalTextView(frame: CGRectMake(0,0, self.view.frame.size.width * 2, self.view.frame.size.height - 10))
        self.textview.fontName = "Wyue-GutiFangsong-NC"
        self.textview.lineSpace = 15.0
        self.textview.titleText = "借口"
        self.textview.backgroundColor = UIColor.clearColor()
        self.textview.bounds = CGRectInset(self.textview.frame, 20.0,0.0)
        self.textview.text = diary.content
        
//        self.textview.userInteractionEnabled = false
        self.scrollview.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        self.scrollview.contentSize = CGSizeMake(self.textview.bounds.size.width + 20.0, self.textview.bounds.size.height - 10)
        self.scrollview.contentOffset = CGPointMake(1000, -10)
        
        self.scrollview.addSubview(self.textview)
        
        
        var mSwipeUpRecognizer = UITapGestureRecognizer(target: self, action: "hideDiary")
        mSwipeUpRecognizer.numberOfTapsRequired = 2
        self.scrollview.addGestureRecognizer(mSwipeUpRecognizer)
        // Do any additional setup after loading the view.
    }
    
    func hideDiary() {
        println("Hide diary")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
