//
//  DiaryHelper.swift
//  Diary
//
//  Created by kevinzhow on 15/2/11.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

let firstFont = "Wyue-GutiFangsong-NC"
let secondFont = "STSongti-SC-Bold"
let janpan = "HiraMinProN-W3"

let defaults = NSUserDefaults.standardUserDefaults()

let currentLanguage = NSLocale.preferredLanguages()[0] as! String

let gussesFont: AnyObject? = currentLanguage == "ja" ? janpan : firstFont

var defaultFont = gussesFont as! String

let screenRect = UIScreen.mainScreen().bounds

let DiaryFont = UIFont(name: defaultFont, size: 18) as UIFont!
let DiaryLocationFont = UIFont(name: defaultFont, size: 16) as UIFont!
let DiaryTitleFont = UIFont(name: defaultFont, size: 18) as UIFont!

let collectionViewTopInset = (screenRect.height - itemHeight)/2.0

let DiaryRed = UIColor(red: 192.0/255.0, green: 23.0/255.0, blue: 48.0/255.0, alpha: 1.0)
let itemHeight:CGFloat = 150.0
let itemSpacing:CGFloat = 0
let itemWidth:CGFloat = 60
let collectionViewWidth = itemWidth * 3 + itemSpacing * 2

let collectionViewDisplayedCells: Int = 3
let collectionViewLeftInsets = (screenRect.width - collectionViewWidth)/2.0

var tutShowed: Bool {

get {
    
    if let tutShowed: Bool = defaults.objectForKey("tutshowed") as? Bool {
        if tutShowed {
            return true
        } else {
            return false
        }
    }else{
        return false
    }
    
}

set (newvalue){
    defaults.setBool(newvalue, forKey: "tutshowed")
}

}


func getTutView() -> UIView {
    
    var view = UIView(frame: screenRect)
    
    view.backgroundColor = UIColor.whiteColor()
    
    var label = DiaryLabel(fontname: defaultFont, labelText: "雙擊返回", fontSize: 24.0, lineHeight: 15.0)
    
    var labelContainer = UIView(frame: CGRectInset(label.frame, -10.0, -10.0))
    
    labelContainer.layer.borderColor = UIColor.blackColor().CGColor
    
    labelContainer.layer.borderWidth = 1.0
    
    label.center = CGPoint(x: labelContainer.frame.size.width/2.0, y: labelContainer.frame.size.height/2.0)
    
    labelContainer.addSubview(label)
    
    labelContainer.center = view.center
    
    view.addSubview(labelContainer)
    
    return view
}

//Coredata
let appDelegate =
UIApplication.sharedApplication().delegate as! AppDelegate

let managedContext = appDelegate.managedObjectContext!

func toggleFont() {

    if let fontName = defaults.objectForKey("defaultFont") as? String {
        switch fontName {
        case firstFont:
            defaults.setObject(secondFont, forKey: "defaultFont")
            defaultFont = secondFont
        case secondFont:
            defaults.setObject(firstFont, forKey: "defaultFont")
            defaultFont = firstFont
        case janpan:
            defaults.setObject(janpan, forKey: "defaultFont")
            defaultFont = janpan
        default:
            break
        }
    }
    
    NSNotificationCenter.defaultCenter().postNotificationName("DiaryChangeFont", object: nil)
}



func randomStringWithLength (len : Int) -> NSString {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    var randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        var length = UInt32 (letters.length)
        var rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return randomString
}

func coverPathWithKey(key: String) -> String {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("/\(key).jpg")
}

func baseCoverURL() -> String {
    return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
}

func diaryButtonWith(#text: String, #fontSize: CGFloat, #width: CGFloat, #normalImageName: String, #highlightedImageName: String) -> UIButton {
    
    return diaryButtonWith(text: text, fontSize: fontSize, width: width, normalImageName: normalImageName, highlightedImageName: highlightedImageName, color: UIColor.whiteColor())

}

func diaryButtonWith(#text: String, #fontSize: CGFloat, #width: CGFloat, #normalImageName: String, #highlightedImageName: String, #color: UIColor) -> UIButton {
    
    var button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    button.frame = CGRectMake(0, 0, width, width)
    
    var font = UIFont(name: defaultFont, size: fontSize) as UIFont!
    let textAttributes: [NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
    var attributedText = NSAttributedString(string: text, attributes: textAttributes)
    button.setAttributedTitle(attributedText, forState: UIControlState.Normal)
    
    button.setBackgroundImage(UIImage(named: normalImageName), forState: UIControlState.Normal)
    button.setBackgroundImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
    
    return button
}


func numberToChinese(number:Int) -> String {
    var numbers = Array(String(number))
    var finalString = ""
    for singleNumber in numbers {
        var string = singleNumberToChinese(singleNumber)
        finalString = "\(finalString)\(string)"
    }
    return finalString
}

func numberToChineseWithUnit(number:Int) -> String {
    var numbers = Array(String(number))
    var units = unitParser(numbers.count)
    var finalString = ""
    
    for (index, singleNumber) in enumerate(numbers) {
        var string = singleNumberToChinese(singleNumber)
        if (!(string == "零" && (index+1) == numbers.count)){
            finalString = "\(finalString)\(string)\(units[index])"
        }
    }

    return finalString
}

func unitParser(unit:Int) -> [String] {
    
    var units = ["万","千","百","十",""].reverse()
    var slicedUnits: ArraySlice<String> = units[0..<(unit)].reverse()
    var final: [String] = Array(slicedUnits)
    return final
}


func singleNumberToChinese(number:Character) -> String {
    switch number {
    case "0":
        return "零"
    case "1":
        return "一"
    case "2":
        return "二"
    case "3":
        return "三"
    case "4":
        return "四"
    case "5":
        return "五"
    case "6":
        return "六"
    case "7":
        return "七"
    case "8":
        return "八"
    case "9":
        return "九"
    default:
        return ""
    }
}

func findLastDayDiary() -> Diary? {
    //2
    let fetchRequest = NSFetchRequest(entityName:"Diary")
    
    println("\(NSDate().beginningOfDay()) \(NSDate().endOfDay())")
    
    fetchRequest.predicate = NSPredicate(format: "(created_at >= %@ ) AND (created_at < %@)", NSDate().beginningOfDay(), NSDate().endOfDay())
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
    //3
    var error: NSError?
    
    var fetchedResults =
    managedContext.executeFetchRequest(fetchRequest,
        error: &error) as! [Diary]?
    
    while(fetchedResults?.count > 1){
        var lastDiary = fetchedResults?.last!
        managedContext.deleteObject(lastDiary!)
        fetchedResults = managedContext.executeFetchRequest(fetchRequest,
                error: &error) as! [Diary]?
    }
    managedContext.save(nil)
    var diary = fetchedResults?.first
    
    return diary
}


extension UIWebView {
    
    func captureView() -> UIImage{
        // tempframe to reset view size after image was created
        var tmpFrame = self.frame
        // set new Frame
        var aFrame = self.frame
        aFrame.size.width = self.sizeThatFits(UIScreen.mainScreen().bounds.size).width
        self.frame = aFrame
        // do image magic
        UIGraphicsBeginImageContextWithOptions(self.sizeThatFits(UIScreen.mainScreen().bounds.size), false, UIScreen.mainScreen().scale)
        var resizedContext = UIGraphicsGetCurrentContext()
        self.layer.renderInContext(resizedContext)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // reset Frame of view to origin
        self.frame = tmpFrame
        
        return image
    }
}

extension Diary {
    func updateTimeWithDate(date: NSDate){
        self.created_at = date
        self.year = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: date)
        self.month = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: date)
    }
}

extension NSDate {
    func beginningOfDay() -> NSDate{
        var calender = NSCalendar.currentCalendar()
        var components = calender.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate: self)
        components.hour = 00
        components.minute = 00
        components.second = 00
        return calender.dateFromComponents(components)!
    }
    
    func endOfDay() -> NSDate {
        var calender = NSCalendar.currentCalendar()
        var components = NSDateComponents()
        components.day = 1
        var date = calender.dateByAddingComponents(components, toDate: self.beginningOfDay(), options: nil)
        date?.dateByAddingTimeInterval(-1)
        return date!
    }
}


