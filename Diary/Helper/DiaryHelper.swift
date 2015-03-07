//
//  DiaryHelper.swift
//  Diary
//
//  Created by kevinzhow on 15/2/11.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

let screenRect = UIScreen.mainScreen().bounds
let DiaryFont = UIFont(name: "Wyue-GutiFangsong-NC", size: 18) as UIFont!
let DiaryRed = UIColor(red: 192.0/255.0, green: 23.0/255.0, blue: 48.0/255.0, alpha: 1.0)
let itemHeight:CGFloat = 150.0
let itemSpacing:CGFloat = 30
let itemWidth:CGFloat = 20
let collectionViewWidth = itemWidth * 3 + itemSpacing * 2

//1
let appDelegate =
UIApplication.sharedApplication().delegate as! AppDelegate

let managedContext = appDelegate.managedObjectContext!


func diaryButtonWith(#text: String, #fontSize: CGFloat, #width: CGFloat, #normalImageName: String, #highlightedImageName: String) -> UIButton {
    
    var button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    button.frame = CGRectMake(0, 0, width, width)
    
    var font = UIFont(name: "Wyue-GutiFangsong-NC", size: fontSize) as UIFont!
    let textAttributes: [NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
    var attributedText = NSAttributedString(string: text, attributes: textAttributes)
    button.setAttributedTitle(attributedText, forState: UIControlState.Normal)
    
    button.setBackgroundImage(UIImage(named: normalImageName), forState: UIControlState.Normal)
    button.setBackgroundImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
    
    return button

}

func numberToChinese(number:Int) -> String {
    var stringNumber = Array(String(number))
    var finalString = ""
    var i:Int
    for i = 0; i < stringNumber.count; ++i {
        var string = singleNumberToChinese(stringNumber[i])
        finalString = "\(finalString)\(string)"
    }
    
    return finalString

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
    
    println("\(NSDate.new().beginningOfDay()) \(NSDate.new().endOfDay())")
    
    fetchRequest.predicate = NSPredicate(format: "(created_at >= %@ ) AND (created_at < %@)", NSDate.new().beginningOfDay(), NSDate.new().endOfDay())
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
        var components = NSDateComponents.new()
        components.day = 1
        var date = calender.dateByAddingComponents(components, toDate: self.beginningOfDay(), options: nil)
        date?.dateByAddingTimeInterval(-1)
        return date!
    }
}
