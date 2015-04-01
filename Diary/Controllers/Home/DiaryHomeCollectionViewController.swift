//
//  DiaryHomeCollectionViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/2/11.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

let reuseIdentifier = "HomeYearCollectionViewCell"

class DiaryHomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    var diarys = [NSManagedObject]()
    
    var diarysGroupInYear = [Int: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController!.delegate = self

        let fetchRequest = NSFetchRequest(entityName:"Diary")
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        if let results = fetchedResults {
            diarys = results
        } else {
            NSLog("Could not fetch \(error), \(error!.userInfo)")
        }
        
        for diary in diarys{
            var diary = diary as Diary
            var date = diary.created_at
            var components = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: date)
            
            if diarysGroupInYear[components] == nil {
                diarysGroupInYear[components] = 1
            }else{
                diarysGroupInYear[components] = diarysGroupInYear[components]! + 1
            }
        }
        
        if  diarysGroupInYear.keys.array.count == 0 {
            var components = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: NSDate())
            diarysGroupInYear[components] = 1
        }

        self.collectionView?.frame = CGRectMake((screenRect.width - collectionViewWidth)/2.0, (screenRect.height - itemHeight)/2.0, collectionViewWidth, itemHeight)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //Dont use this if you are using storyboard
//        self.collectionView!.registerClass(HomeYearCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        var yearLayout = DiaryLayout()

        yearLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView?.setCollectionViewLayout(yearLayout, animated: false)

        moveToThisMonth()
        // Do any additional setup after loading the view.
    }
    
    
    func moveToThisMonth() {
        
        var currentMonth = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
        
        if (diarys.count > 0){
            var diary = diarys.last as Diary
            
            if (currentMonth >  diary.month.integerValue) {
                var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryYearCollectionViewController") as DiaryYearCollectionViewController
                
                dvc.year = diary.year.integerValue
                
                self.navigationController!.pushViewController(dvc, animated: true)
            }else{
                var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryMonthDayCollectionViewController") as DiaryMonthDayCollectionViewController
                
                dvc.year = diary.year.integerValue
                dvc.month = diary.month.integerValue
                
                self.navigationController!.pushViewController(dvc, animated: true)
            }
        }else{
            var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryMonthDayCollectionViewController") as DiaryMonthDayCollectionViewController
            var filePath = NSBundle.mainBundle().pathForResource("poem", ofType: "json")
            var JSONData = NSData(contentsOfFile: filePath!, options: NSDataReadingOptions.MappedRead, error: nil)
            var jsonObject = NSJSONSerialization.JSONObjectWithData(JSONData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            var poems = jsonObject.valueForKey("poems") as NSArray
            
            for poem in poems{
                
                var poem =  poem as NSDictionary
                let entity =  NSEntityDescription.entityForName("Diary", inManagedObjectContext: managedContext)
                
                let newdiary = Diary(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                
                newdiary.content = poem.valueForKey("content") as String
                newdiary.title = poem.valueForKey("title") as? String
                newdiary.location = poem.valueForKey("location") as String
                
                newdiary.updateTimeWithDate(NSDate())
                dvc.month = newdiary.month.integerValue
                dvc.year = newdiary.year.integerValue

            }
            
            self.navigationController!.pushViewController(dvc, animated: true)
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
        }
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        if diarysGroupInYear.keys.array.count == 0 {
            return 1
        }else{
            return diarysGroupInYear.keys.array.count
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> HomeYearCollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as HomeYearCollectionViewCell
        
        var yearText = diarysGroupInYear.keys.array[indexPath.row]
        cell.textInt = diarysGroupInYear.keys.array[indexPath.row]
        cell.labelText = "\(numberToChinese(cell.textInt)) 年"

        // Configure the cell
    
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var numberOfCells:Int = 1
        
        if diarysGroupInYear.keys.array.count != 0 {
            numberOfCells = diarysGroupInYear.keys.array.count
        }
        
        if (numberOfCells < 3) {
            var edgeInsets = (collectionViewWidth - ((CGFloat(numberOfCells)*itemWidth)+(CGFloat(numberOfCells)-1) * itemSpacing))/2.0
            return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
        }else{
            return UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryYearCollectionViewController") as DiaryYearCollectionViewController
        dvc.year = diarysGroupInYear.keys.array[indexPath.row]
//        dvc.collectionView?.dataSource = collectionView.dataSource

        self.navigationController!.pushViewController(dvc, animated: true)
        
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        var animator = DiaryAnimator()
        if (operation == UINavigationControllerOperation.Push) {
            animator.fromView = fromVC.view
            return animator
        }
        else if (operation == UINavigationControllerOperation.Pop) {
            animator.fromView = fromVC.view
            animator.pop = true
            return animator
        }
        else {
            return nil;
        }
    }
    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
