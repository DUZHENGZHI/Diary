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
let secondFont = "Wyue-GutiFangsong-NC"
let janpan = "HiraMinProN-W3"

let defaults = NSUserDefaults.standardUserDefaults()

let currentLanguage = NSLocale.preferredLanguages()[0]

typealias CancelableTask = (cancel: Bool) -> Void

var defaultFont: String {
    get {
        return defaults.objectForKey("defaultFont") as! String
    }

    set (newValue) {
        defaults.setObject(newValue, forKey: "defaultFont")
    }
}

let screenRect = UIScreen.mainScreen().bounds

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

let collectionViewTopInset = (screenRect.height - itemHeight)/2.0


let DiaryRed = UIColor(red: 192.0/255.0, green: 23.0/255.0, blue: 48.0/255.0, alpha: 1.0)
let itemHeight:CGFloat = screenRect.height
let itemSpacing:CGFloat = 0
let itemWidth:CGFloat = 60
let collectionViewWidth = itemWidth * 3

let collectionViewDisplayedCells: Int = 3
var collectionViewLeftInsets: CGFloat {
    get {

        if portrait {
            let portrait = (screenRect.width - collectionViewWidth)/2.0
            return portrait
        }else {
            let landInset = (screenRect.height - collectionViewWidth)/2.0
            return landInset
        }
    }
}

func delay(time: NSTimeInterval, work: dispatch_block_t) -> CancelableTask? {
    
    var finalTask: CancelableTask?
    
    let cancelableTask: CancelableTask = { cancel in
        if cancel {
            finalTask = nil // key
            
        } else {
            dispatch_async(dispatch_get_main_queue(), work)
        }
    }
    
    finalTask = cancelableTask
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        if let task = finalTask {
            task(cancel: false)
        }
    }
    
    return finalTask
}

func cancel(cancelableTask: CancelableTask?) {
    cancelableTask?(cancel: true)
}

var portrait: Bool {
    get {
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        if interfaceOrientation == .Portrait ||  interfaceOrientation == .PortraitUpsideDown{
            return true
        }else {
            return false
        }
    }
}

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

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImage {
    
    func drawImage(inputImage: UIImage, frame: CGRect) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.drawInRect(CGRectMake(0.0, 0.0, self.size.width, self.size.height))
        inputImage.drawInRect(frame)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }
}


func getTutView() -> UIView {
    
    let view = UIView(frame: screenRect)
    
    view.backgroundColor = UIColor.whiteColor()
    
    let label = DiaryLabel(fontname: defaultFont, labelText: "雙擊返回", fontSize: 24.0, lineHeight: 15.0)
    
    label.frame = CGRectMake(0, 0, label.labelSize!.width, label.labelSize!.height)
    
    let labelContainer = UIView(frame: CGRectInset(label.frame, -10.0, -10.0))
    
    labelContainer.layer.borderColor = UIColor.blackColor().CGColor
    
    labelContainer.layer.borderWidth = 1.0
    
    label.center = CGPoint(x: labelContainer.frame.size.width/2.0, y: labelContainer.frame.size.height/2.0)
    
    labelContainer.addSubview(label)
    
    labelContainer.center = view.center
    
    view.addSubview(labelContainer)
    
    return view
}

//Coredata

var managedContext: NSManagedObjectContext? = {
    return managedObjectContext
}()

// MARK: - Core Data stack

var applicationDocumentsDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "kevinzhow.Diary" in the application's documents Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1]
}()

var cloudDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "kevinzhow.Diary" in the application's documents Application Support directory.
    var cloudRoot = icloudIdentifier()
    let url = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier("\(cloudRoot)")
    debugPrint("\(url)")
    return url!
}()

var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = NSBundle.mainBundle().URLForResource("Diary", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
}()

var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    
    
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    let url = applicationDocumentsDirectory.URLByAppendingPathComponent("Diary.sqlite")
    var error: NSError? = nil
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
        try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: storeOptions)
    } catch var error1 as NSError {
        error = error1
        coordinator = nil
        // Report any error we got.
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
        dict[NSLocalizedFailureReasonErrorKey] = failureReason
        dict[NSUnderlyingErrorKey] = error
        error = NSError(domain: "Catch.Diary.Error", code: 9999, userInfo: dict)
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(error), \(error!.userInfo)")
        abort()
    } catch {
        fatalError()
    }
    
    return coordinator
}()

var managedObjectContext: NSManagedObjectContext? = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = persistentStoreCoordinator
    if coordinator == nil {
        return nil
    }
    var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
}()

var storeOptions: [NSObject : AnyObject] = {
    return [
        NSMigratePersistentStoresAutomaticallyOption:true,
        NSInferMappingModelAutomaticallyOption: true,
        NSPersistentStoreUbiquitousContentNameKey : "CatchDiary",
        NSPersistentStoreUbiquitousPeerTokenOption: "c405d8e8a24s11e3bbec425861s862bs"]
}()

// MARK: - Core Data Saving support

func saveContext () {
    if let moc = managedObjectContext {
        var error: NSError? = nil
        if moc.hasChanges {
            do {
                try moc.save()
            } catch let error1 as NSError {
                error = error1
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}

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
    
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return randomString
}

func diaryButtonWith(text text: String, fontSize: CGFloat, width: CGFloat, normalImageName: String, highlightedImageName: String) -> UIButton {
    
    let button = UIButton(type: UIButtonType.Custom) //创建自定义 Button
    button.frame = CGRectMake(0, 0, width, width) //设定 Button 的大小
    
    let font = UIFont(name: "Wyue-GutiFangsong-NC", size: fontSize) as UIFont!
    let textAttributes: [String : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
    let attributedText = NSAttributedString(string: text, attributes: textAttributes)
    button.setAttributedTitle(attributedText, forState: UIControlState.Normal) //设置 Button 字体
    
    button.setBackgroundImage(UIImage(named: normalImageName), forState: UIControlState.Normal) //设置默认 Button 样式
    button.setBackgroundImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted) // 设置 Button 被按下时候的样式
    
    return button
    
}


extension UIButton {
    func customButtonWith(text text: String, fontSize: CGFloat, width: CGFloat, normalImageName: String, highlightedImageName: String){
        
        let font = UIFont(name: defaultFont, size: fontSize) as UIFont!
        let textAttributes: [String : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        
        self.setAttributedTitle(attributedText, forState: UIControlState.Normal)
        
        self.setBackgroundImage(UIImage(named: normalImageName), forState: UIControlState.Normal)
        self.setBackgroundImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
    }
}




func numberToChinese(number:Int) -> String {
    let numbers = Array(String(number).characters)
    var finalString = ""
    for singleNumber in numbers {
        let string = singleNumberToChinese(singleNumber)
        finalString = "\(finalString)\(string)"
    }
    return finalString
}

func numberToChineseWithUnit(number:Int) -> String {
    let numbers = Array(String(number).characters)
    var units = unitParser(numbers.count)
    var finalString = ""
    
    for (index, singleNumber) in numbers.enumerate() {
        let string = singleNumberToChinese(singleNumber)
        if (!(string == "零" && (index+1) == numbers.count)){
            finalString = "\(finalString)\(string)\(units[index])"
        }
    }

    return finalString
}

func unitParser(unit:Int) -> [String] {
    
    var units = Array(["万","千","百","十",""].reverse())
    let parsedUnits = units[0..<(unit)].reverse()
    let slicedUnits: ArraySlice<String> = ArraySlice(parsedUnits)
    let final: [String] = Array(slicedUnits)
    return final
}

func icloudIdentifier() -> String {
    let teamID = "iCloud."
    let bundleID = NSBundle.mainBundle().bundleIdentifier!
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
    let fetchRequest = NSFetchRequest(entityName:"Diary")
    
    debugPrint("\(NSDate().beginningOfDay()) \(NSDate().endOfDay())")
    
    fetchRequest.predicate = NSPredicate(format: "(created_at >= %@ ) AND (created_at < %@)", NSDate().beginningOfDay(), NSDate().endOfDay())
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]

    do {
        var fetchedResults = try managedContext?.executeFetchRequest(fetchRequest) as! [Diary]
        while(fetchedResults.count > 1){
            let lastDiary = fetchedResults.last!
            managedContext?.deleteObject(lastDiary)
            fetchedResults = try managedContext?.executeFetchRequest(fetchRequest) as! [Diary]
        }
        do {
            try managedContext?.save()
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
        aFrame.size.width = self.sizeThatFits(UIScreen.mainScreen().bounds.size).width
        self.frame = aFrame
        // do image magic
        UIGraphicsBeginImageContextWithOptions(self.sizeThatFits(UIScreen.mainScreen().bounds.size), false, UIScreen.mainScreen().scale)
        let resizedContext = UIGraphicsGetCurrentContext()
        self.layer.renderInContext(resizedContext!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // reset Frame of view to origin
        self.frame = tmpFrame
        
        return image
    }
}

extension Diary {
    func updateTimeWithDate(date: NSDate){
        self.created_at = date
        self.year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: date)
        self.month = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: date)
    }
}

extension NSDate {
    func beginningOfDay() -> NSDate{
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: self)
        components.hour = 00
        components.minute = 00
        components.second = 00
        return calender.dateFromComponents(components)!
    }
    
    func endOfDay() -> NSDate {
        let calender = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.day = 1
        let date = calender.dateByAddingComponents(components, toDate: self.beginningOfDay(), options: [])
        date?.dateByAddingTimeInterval(-1)
        return date!
    }
}


