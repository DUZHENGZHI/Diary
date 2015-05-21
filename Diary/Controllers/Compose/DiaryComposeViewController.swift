//
//  DiaryComposeViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/4.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData
import NCChineseConverter

let titleTextViewHeight:CGFloat = 30.0
let contentMargin:CGFloat = 20.0

class DiaryComposeViewController: DiaryBaseViewController{

    var composeView:UITextView!
    var locationTextView:UITextView!
    var titleTextView:UITextView!
    var storage:NSTextStorage!
    var keyboardSize:CGSize = CGSizeMake(0, 0)
    var finishButton:UIButton!
    var imageView:UIImageView!
    var imageButton:UIButton!
    
    var imagePicker = UIImagePickerController()
    
    var diaryKeyString: String?
    
    var diary:Diary?
    
    var locationHelper: DiaryLocationHelper = DiaryLocationHelper()
    
    var changeText = false
    
    var changeTextCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        storage = DiaryTextStorage()
        imagePicker.delegate = self
        let containerSize = CGSize(width: screenRect.width, height: CGFloat.max)
        let container = NSTextContainer(size: containerSize)

        container.widthTracksTextView = true
        let layoutManager = NSLayoutManager()
//        layoutManager.delegate = self

        storage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(container)

        composeView = UITextView(frame: CGRectMake(0, contentMargin + titleTextViewHeight, screenRect.width, screenRect.height), textContainer: container)
        composeView.font = DiaryFont
        composeView.editable = true
        composeView.userInteractionEnabled = true
        composeView.delegate = self
        composeView.textContainerInset = UIEdgeInsetsMake(contentMargin, contentMargin, contentMargin, contentMargin)

        //Add LocationTextView
        locationTextView = UITextView(frame: CGRectMake(0, composeView.frame.size.height - 30.0, screenRect.width - 60.0, 30.0))
        locationTextView.font = DiaryLocationFont
        locationTextView.editable = true
        locationTextView.userInteractionEnabled = true
        locationTextView.alpha = 0.0
        locationTextView.bounces = false
        locationTextView.delegate = self

        //Add titleView

        titleTextView = UITextView(frame: CGRectMake(contentMargin, contentMargin/2, screenRect.width - 60.0, titleTextViewHeight))
        titleTextView.font = DiaryTitleFont
        titleTextView.editable = true
        titleTextView.userInteractionEnabled = true
        titleTextView.bounces = false
        titleTextView.delegate = self

        if let diary = diary {
            composeView.text = diary.content
            self.composeView.contentOffset = CGPointMake(0, self.composeView.contentSize.height)
            locationTextView.text = diary.location
            locationTextView.alpha = 1.0
            if let title = diary.title {
                titleTextView.text = title
            }else{
                titleTextView.text = "\(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitDay, fromDate: diary.created_at))) 日"
            }
        }else{
            var date = NSDate()
            titleTextView.text = "\(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitDay, fromDate: date))) 日"
        }

        composeView.becomeFirstResponder()

        self.view.addSubview(composeView)

        self.view.addSubview(locationTextView)

        self.view.addSubview(titleTextView)

        //Add finish button

        finishButton = diaryButtonWith(text: "完",  fontSize: 18.0,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")

        finishButton.center = CGPointMake(screenRect.width - 20, screenRect.height - 30)

        finishButton.addTarget(self, action: "finishCompose:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //Add image button
        
        imageButton = diaryButtonWith(text: "圖",  fontSize: 18.0,  width: 50.0,  normalImageName: "OvalBlack", highlightedImageName: "OvalBlack", color: UIColor.blackColor())
        
        imageButton.addTarget(self, action: "pickImage", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.addSubview(finishButton)
        
//        self.view.addSubview(imageButton)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34.0, height: 34.0))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.size.height/2.0
        imageView.layer.masksToBounds = true
        imageView.hidden = true
        self.view.addSubview(imageView)

        self.finishButton.center = CGPointMake(self.view.frame.width - self.finishButton.frame.size.height/2.0 - 10, self.view.frame.height  - self.finishButton.frame.size.height/2.0 - 10)
        
        imageButton.center = CGPointMake(finishButton.center.x, finishButton.center.y - finishButton.frame.size.height)
        
        imageView.center = imageButton.center

        self.locationTextView.center = CGPointMake(self.locationTextView.frame.size.width/2.0 + 20.0, self.finishButton.center.y)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAddress:", name: "DiaryLocationUpdated", object: nil)

        // Do any additional setup after loading the view.
    }

    func updateAddress(notification: NSNotification) {

        if let address = notification.object as? String {

            println("Author at \(address)")

            if let lastLocation = diary?.location {
                locationTextView.text = diary?.location
            }else {
                locationTextView.text = "于 \(address)"
            }


            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.locationTextView.alpha = 1.0

                }, completion: nil)

            locationHelper.locationManager.stopUpdatingLocation()
        }


    }

    func finishCompose(button: UIButton) {
        print("Finish compose \n")

        self.composeView.endEditing(true)
        self.locationTextView.endEditing(true)

        if (composeView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 1){

            if let diary = diary {

                diary.content = composeView.text
                diary.location = locationTextView.text
                diary.title = titleTextView.text
                
                if let coverKey = diaryKeyString {
                    diary.coverCloudKey = coverKey
                    diary.coverLocalURL = coverPathWithKey(coverKey)
                }

            }else{

                let entity =  NSEntityDescription.entityForName("Diary", inManagedObjectContext: managedContext)

                let newdiary = Diary(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                newdiary.content = composeView.text

                if let address  = locationHelper.address {
                    newdiary.location = address
                }

                if let title = titleTextView.text {
                    newdiary.title = title
                }
                
                if let coverKey = diaryKeyString {
                    newdiary.coverCloudKey = coverKey
                    newdiary.coverLocalURL = coverPathWithKey(coverKey)
                }

                newdiary.updateTimeWithDate(NSDate())
            }

            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }

        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func pickImage() {
        self.pickImageFromAlbum()
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
                    self.composeView.frame = CGRectMake(0, contentMargin + titleTextViewHeight, self.composeView.frame.size.width,  self.view.frame.height - newKeyboardHeight - 40.0 - self.finishButton.frame.size.height/2.0 - (contentMargin + titleTextViewHeight))
                }

                self.finishButton.center = CGPointMake(self.view.frame.width - self.finishButton.frame.size.height/2.0 - 10, self.view.frame.height - newKeyboardHeight - self.finishButton.frame.size.height/2.0 - 10)
                
                self.imageButton.center = CGPointMake(self.finishButton.center.x, self.finishButton.center.y - self.finishButton.frame.size.height)
                
                self.imageView.center = self.imageButton.center

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

extension DiaryComposeViewController: UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {


    func pickImageFromAlbum(){
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    
    func pickImageFromCamera(){
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){

            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        println("Image loaded")
        
        self.imageView.image = image
        
        self.imageView.hidden = false
        
        var ramdomString = randomStringWithLength(32)
        
        diaryKeyString = ramdomString as String
        
        var data = UIImageJPEGRepresentation(image, 0.9)
        
        var imagePath = coverPathWithKey(diaryKeyString!)
        
        data.writeToFile(imagePath, atomically: true)
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func textViewDidChange(textView: UITextView) {
        
        if textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            
            var text = textView.text.substringFromIndex(textView.text.endIndex.predecessor())
            var s = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_")
            if let r = text.rangeOfCharacterFromSet(s) {
                println("Skip Convert")
            }else{
                println("Do Convert")
                textView.text = (textView.text as NSString).chineseStringHK()
            }
        }

        updateTextViewSizeForKeyboardHeight(keyboardSize.height)
    }


}
