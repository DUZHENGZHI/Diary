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

let firstFont = "FZLONGZFW--GB1-0"
let janpan = "HiraMinProN-W3"

let defaults = UserDefaults.standard

let currentLanguage = NSLocale.preferredLanguages[0]

typealias CancelableTask = (_ cancel: Bool) -> Void

var defaultFont: String {
    get {
        return firstFont
    }

    set (newValue) {
        defaults.set(newValue, forKey: "defaultFont")
    }
}

func screenRect() -> CGRect {
    return UIScreen.main.bounds
}

var DiaryFont: UIFont {

    get {
        return UIFont(name: defaultFont, size: 18) as UIFont!
    }

}

var DiaryLocationFont: UIFont {
    get {
       return UIFont(name: defaultFont, size: 16) as UIFont!
    }
}


var DiaryTitleFont: UIFont {
    get {
        return UIFont(name: defaultFont, size: 18) as UIFont!
    }
}

let collectionViewTopInset = (screenRect().height - itemHeight())/2.0


let DiaryRed = UIColor(red: 192.0/255.0, green: 23.0/255.0, blue: 48.0/255.0, alpha: 1.0)

func itemHeight() -> CGFloat {
    return screenRect().height - 100
}

let itemSpacing:CGFloat = 0
let itemWidth:CGFloat = 60
let collectionViewWidth = itemWidth * 3

let collectionViewDisplayedCells: Int = 3
var collectionViewLeftInsets: CGFloat {
    get {

        if portrait {
            let portrait = (screenRect().width - collectionViewWidth)/2.0
            return portrait
        }else {
            let landInset = (screenRect().height - collectionViewWidth)/2.0
            return landInset
        }
    }
}



var portrait: Bool {
    get {
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        
        if interfaceOrientation == .portrait ||  interfaceOrientation == .portraitUpsideDown{
            return true
        }else {
            return false
        }
    }
}

var tutShowed: Bool {

    get {
        
        if let tutShowed: Bool = defaults.object(forKey: "tutshowed") as? Bool {
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
        defaults.set(newvalue, forKey: "tutshowed")
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIImage {
    
    func drawImage(inputImage: UIImage, frame: CGRect) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.draw(in: CGRect(x: 0.0,y: 0.0,width: self.size.width,height: self.size.height))
        inputImage.draw(in: frame)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
        
    }
}


func getTutView() -> UIView {
    
    let view = UIView(frame: screenRect())
    
    view.backgroundColor = UIColor.white
    
    let label = DiaryLabel(fontname: defaultFont, labelText: "双击返回", fontSize: 24.0, lineHeight: 15.0)
    
    label.frame = CGRect(x: 0, y: 0, width: label.labelSize!.width, height: label.labelSize!.height)
    
    let rect = label.frame
    let labelContainer = UIView(frame: rect.insetBy(dx: -10, dy: -10))
    
    labelContainer.layer.borderColor = UIColor.black.cgColor
    
    labelContainer.layer.borderWidth = 1.0
    
    label.center = CGPoint(x: labelContainer.frame.size.width/2.0, y: labelContainer.frame.size.height/2.0)
    
    labelContainer.addSubview(label)
    
    labelContainer.center = view.center
    
    view.addSubview(labelContainer)
    
    return view
}


func randomStringWithLength (len : Int) -> NSString {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for _ in 0 ..< len {
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    
    return randomString
}

func diaryButtonWith(text: String, fontSize: CGFloat, width: CGFloat, normalImageName: String, highlightedImageName: String) -> UIButton {
    
    let button = UIButton(type: UIButtonType.custom) //创建自定义 Button
    button.frame = CGRect(x: 0, y:0, width: width, height: width) //设定 Button 的大小
    
    let font = UIFont(name: "Wyue-GutiFangsong-NC", size: fontSize) as UIFont!
    let textAttributes: [NSAttributedStringKey : AnyObject] = [NSAttributedStringKey.font: font!, NSAttributedStringKey.foregroundColor: UIColor.white]
    let attributedText = NSAttributedString(string: text, attributes: textAttributes)
    button.setAttributedTitle(attributedText, for: [UIControlState.normal]) //设置 Button 字体
    
    button.setBackgroundImage(UIImage(named: normalImageName), for: [UIControlState.normal]) //设置默认 Button 样式
    button.setBackgroundImage(UIImage(named: highlightedImageName), for: [UIControlState.highlighted]) // 设置 Button 被按下时候的样式
    
    return button
    
}


extension UIButton {
    func customButtonWith(text: String, fontSize: CGFloat, width: CGFloat, normalImageName: String, highlightedImageName: String){
        
        let font = UIFont(name: defaultFont, size: fontSize) as UIFont!
        let textAttributes: [NSAttributedStringKey : AnyObject] = [NSAttributedStringKey.font: font!, NSAttributedStringKey.foregroundColor: UIColor.white]
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        
        self.setAttributedTitle(attributedText, for: [UIControlState.normal])
        
        self.setBackgroundImage(UIImage(named: normalImageName), for: [UIControlState.normal])
        self.setBackgroundImage(UIImage(named: highlightedImageName), for: [UIControlState.highlighted])
    }
}




func numberToChinese(number:Int) -> String {
    let numbers = Array(String(number))
    var finalString = ""
    for singleNumber in numbers {
        let string = singleNumberToChinese(number: singleNumber)
        finalString = "\(finalString)\(string)"
    }
    return finalString
}

func numberToChineseWithUnit(number:Int) -> String {
    let numbers = Array(String(number))
    var units = unitParser(unit: numbers.count)
    var finalString = ""
    
    for (index, singleNumber) in numbers.enumerated() {
        let string = singleNumberToChinese(number: singleNumber)
        if (!(string == "零" && (index+1) == numbers.count)){
            if (index == numbers.count - 1) {
                finalString = "\(finalString)\(string)"
            } else {
                finalString = "\(finalString)\(string)\(units[2*index + 1])"
            }
        }
    }

    return finalString
}

func unitParser(unit:Int) -> [String] {
    let units = Array(["万","千","百","十",""].reversed())
    let slicedUnits: ArraySlice<String> = ArraySlice(units)
    let final: [String] = Array(slicedUnits)
    return final
}

func icloudIdentifier() -> String {
    let teamID = "iCloud."
    let bundleID = Bundle.main.bundleIdentifier!
    let cloudRoot = "\(teamID)\(bundleID).sync"
    
    return cloudRoot
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
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Diary")
    
    debugPrint("\(NSDate().beginningOfDay()) \(NSDate().endOfDay())")
    
    fetchRequest.predicate = NSPredicate(format: "(created_at >= %@ ) AND (created_at < %@)", NSDate().beginningOfDay(), NSDate().endOfDay())
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]

    do {
        var fetchedResults = try DiaryCoreData.sharedInstance.managedContext?.fetch(fetchRequest) as! [Diary]
        while(fetchedResults.count > 1){
            let lastDiary = fetchedResults.last!
            DiaryCoreData.sharedInstance.managedContext?.delete(lastDiary)
            fetchedResults = try DiaryCoreData.sharedInstance.managedContext?.fetch(fetchRequest) as! [Diary]
        }
        do {
            try DiaryCoreData.sharedInstance.managedContext?.save()
        } catch _ {
        }
        let diary = fetchedResults.first
        
        return diary
    } catch _ {
        return nil
    }

    

}


extension UIWebView {
    
    func captureView() -> UIImage{
        // tempframe to reset view size after image was created
        let tmpFrame = self.frame
        // set new Frame
        var aFrame = self.frame
        aFrame.size.width = self.sizeThatFits(UIScreen.main.bounds.size).width
        self.frame = aFrame
        // do image magic
        UIGraphicsBeginImageContextWithOptions(self.sizeThatFits(UIScreen.main.bounds.size), false, UIScreen.main.scale)
        let resizedContext = UIGraphicsGetCurrentContext()
        self.layer.render(in: resizedContext!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // reset Frame of view to origin
        self.frame = tmpFrame
        
        return image!
    }
}

extension Diary {
    func updateTimeWithDate(date: NSDate){
        self.created_at = date
        self.year = NSCalendar.current.component(Calendar.Component.year, from: date as Date) as NSNumber
        self.month = NSCalendar.current.component(Calendar.Component.month, from: date as Date) as NSNumber
    }
}

extension NSDate {
    func beginningOfDay() -> NSDate{
        let calender = NSCalendar.current
        let componentsUnits: Set = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day]
        var components = calender.dateComponents(componentsUnits, from: self as Date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        return calender.date(from: components)! as NSDate
    }
    
    func endOfDay() -> NSDate {
        let calender = NSCalendar.current
        let components = NSDateComponents()
        components.day = 1
        var date = calender.date(byAdding: components as DateComponents, to: self.beginningOfDay() as Date)
        date?.addTimeInterval(-1)
        return date! as NSDate
    }
}

extension Array {
    
    subscript (safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}


