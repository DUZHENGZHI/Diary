//
//  DiaryComposeViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/4.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

let titleTextViewHeight:CGFloat = 30.0
let contentMargin:CGFloat = 20.0
let locationHelper: DiaryLocationHelper = DiaryLocationHelper()

class DiaryComposeViewController: DiaryBaseViewController{

    @IBOutlet weak var locationTextViewToBottom: NSLayoutConstraint!
    
    @IBOutlet var composeView: UITextView!
    
    @IBOutlet weak var locationTextView: UITextView!
    
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var finishButton: UIButton!
    
    var keyboardSize:CGSize = CGSize(width:0 , height: 0)
    
    var diaryKeyString: String?
    
    var diary:Diary?
    
    var changeText = false
    
    var changeTextCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let textAttributes: [String : Any]! = [NSAttributedStringKey.font.rawValue: DiaryFont, NSAttributedStringKey.verticalGlyphForm.rawValue: 1, NSAttributedStringKey.paragraphStyle.rawValue: paragraphStyle, NSAttributedStringKey.kern.rawValue: 3.0]

        composeView.typingAttributes = textAttributes
        composeView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        //Add LocationTextView
        locationTextView.font = UIFont(name: defaultFont, size: 16) as UIFont!

        locationTextView.alpha = 0.0
        locationTextView.bounces = false
        locationTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        locationTextView.delegate = self

        //Add titleView

        titleTextView.font = DiaryFont
        titleTextView.bounces = false
        titleTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleTextView.delegate = self

        if let diary = diary {
            composeView.text = diary.content
            self.composeView.contentOffset = CGPoint(x: 0, y: self.composeView.contentSize.height)
            locationTextView.text = diary.location
            locationTextView.alpha = 1.0
            if let title = diary.title {
                titleTextView.text = title
            }else{
                titleTextView.text = "\(numberToChineseWithUnit(number: NSCalendar.current.component(Calendar.Component.day, from: diary.created_at as Date))) 日"
            }
        }else{
            let date = NSDate()
            titleTextView.text = "\(numberToChineseWithUnit(number: NSCalendar.current.component(Calendar.Component.day, from: date as Date))) 日"
        }

        composeView.becomeFirstResponder()


        //Add finish button

        finishButton.customButtonWith(text: "完",  fontSize: 18.0,  width: 50.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")

        finishButton.addTarget(self, action: #selector(finishCompose(button:)), for: UIControlEvents.touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAddress), name: NSNotification.Name(rawValue: "DiaryLocationUpdated"), object: nil)

        updateAddress()
        // Do any additional setup after loading the view.
    }

    @objc func updateAddress() {

        if let address = locationHelper.address {

            debugPrint("Author at \(address)")

            if let _ = diary?.location {
                locationTextView.text = diary?.location
            }else {
                locationTextView.text = "于 \(address)"
            }

            UIView.animate(withDuration: 0.5, delay: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations:
                { [weak self] in
                    self?.locationTextView.alpha = 1.0

                }, completion: nil)

            locationHelper.locationManager.stopUpdatingLocation()
        }

    }

    @objc func finishCompose(button: UIButton) {

        self.composeView.endEditing(true)
        
        self.locationTextView.endEditing(true)

        if (composeView.text.lengthOfBytes(using: String.Encoding.utf8) > 1){

            let translationtext = composeView.text
            
            if let managedContext = DiaryCoreData.sharedInstance.managedContext {
            
                if let diary = diary {

                    diary.content = translationtext!
                    diary.location = locationTextView.text
                    diary.title = titleTextView.text
                    
                    if let DiaryID = diary.id {
                        
                        fetchCloudRecordWithID(recordID: DiaryID, complete: { (record) -> Void in
                            if let record = record {
                                updateRecord(diary: diary, record: record)
                            }
                        })
                    }
                    
                }else{

                    let entity =  NSEntityDescription.entity(forEntityName: "Diary", in: managedContext)

                    let newdiary = Diary(entity: entity!,
                                         insertInto:managedContext)
                    
                    newdiary.id = randomStringWithLength(len: 32) as String
                    
                    newdiary.content = translationtext!

                    if let address  = locationHelper.address {
                        newdiary.location = address
                    }

                    if let title = titleTextView.text {
                        newdiary.title = title
                    }
                    
                    newdiary.updateTimeWithDate(date: NSDate())
                    
                    saveNewRecord(diary: newdiary)
                }

                do {
                    try managedContext.save()
                } catch let error as NSError {
                    debugPrint("Could not save \(error), \(error.userInfo)")
                }
            }

        }

        self.dismiss(animated: true, completion: nil)
    }

    func updateTextViewSizeForKeyboardHeight(keyboardHeight: CGFloat) {

        let newKeyboardHeight = keyboardHeight

        UIView.animate(withDuration: 0.5, delay: 0, options: [UIViewAnimationOptions.curveEaseInOut], animations:
            { [weak self] in

                self?.locationTextViewToBottom.constant = newKeyboardHeight + 20
                
                self?.view.layoutIfNeeded()

            }, completion: nil)
    }

    @objc func keyboardDidShow(notification: NSNotification) {

        if let rectValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            keyboardSize = rectValue.cgRectValue.size
            updateTextViewSizeForKeyboardHeight(keyboardHeight: keyboardSize.height)
        }
    }

    @objc func keyboardDidHide(notification: NSNotification) {
        updateTextViewSizeForKeyboardHeight(keyboardHeight: 0)
    }
    
    deinit {
        print("Diary Compose Deinit")
    }


}

extension DiaryComposeViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            composeView.becomeFirstResponder()
            return false
        }
        
        return true
    }
}
