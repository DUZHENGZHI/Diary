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

class DiaryHomeCollectionViewController: DiaryBaseCollecitionViewController {
    
    var diarys = [NSManagedObject]()
    
    var fetchedResultsController : NSFetchedResultsController!
    
    var yearsCount: Int = 1
    
    var sectionsCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController!.delegate = self

        let fetchRequest = NSFetchRequest(entityName:"Diary")
        
        let entity =  NSEntityDescription.entityForName("Diary", inManagedObjectContext: managedContext)
        
        var error: NSError?
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext, sectionNameKeyPath: "year",
            cacheName: nil)
        
        refetch()
        
        collectionView.registerClass(HomeYearCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        self.collectionView?.frame = CGRectMake((screenRect.width - collectionViewWidth)/2.0, (screenRect.height - itemHeight)/2.0, collectionViewWidth, itemHeight)
        collectionView.dataSource = self
        
        var yearLayout = DiaryLayout()
        yearLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView.setCollectionViewLayout(yearLayout, animated: false)

        // Do any additional setup after loading the view.
    }
    
    
    func refetch() {
        
        var error: NSError? = nil
        if (!fetchedResultsController.performFetch(&error)){
            println("Error: \(error?.localizedDescription)")
        }else{
            
            var fetchedResults = fetchedResultsController.fetchedObjects as! [NSManagedObject]
            
            if (fetchedResults.count == 0){
                println("Present empty year")
            }else{
                
                if let sectionsCount = fetchedResultsController.sections?.count {
                    
                    yearsCount = sectionsCount
                    diarys = fetchedResults
                    
                }else {
                    sectionsCount = 0
                    yearsCount = 1
                }
            }
            
            moveToThisMonth()
        }
    }
    
    func moveToThisMonth() {
        
        var currentMonth = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
        
        if (diarys.count > 0){
            var diary = diarys.last as! Diary
            
            if (currentMonth >  diary.month.integerValue) {
                var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryYearCollectionViewController") as! DiaryYearCollectionViewController
                
                dvc.year = diary.year.integerValue
                
                self.navigationController!.pushViewController(dvc, animated: true)
            }else{
                var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryMonthDayCollectionViewController") as! DiaryMonthDayCollectionViewController
                
                dvc.year = diary.year.integerValue
                dvc.month = diary.month.integerValue
                
                self.navigationController!.pushViewController(dvc, animated: true)
            }
        }else{
            var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryMonthDayCollectionViewController") as! DiaryMonthDayCollectionViewController
            var filePath = NSBundle.mainBundle().pathForResource("poem", ofType: "json")
            var JSONData = NSData(contentsOfFile: filePath!, options: NSDataReadingOptions.MappedRead, error: nil)
            var jsonObject = NSJSONSerialization.JSONObjectWithData(JSONData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
            var poemsCollection = jsonObject.valueForKey("poems") as! [String: AnyObject]
            
            var poems = currentLanguage == "ja" ?  (poemsCollection["ja"] as! NSArray) : ( poemsCollection["cn"] as! NSArray)
            
            for poem in poems{
                
                var poem =  poem as! NSDictionary
                let entity =  NSEntityDescription.entityForName("Diary", inManagedObjectContext: managedContext)
                
                let newdiary = Diary(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                
                newdiary.content = poem.valueForKey("content") as! String
                newdiary.title = poem.valueForKey("title") as? String
                newdiary.location = poem.valueForKey("location") as! String
                
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

}

extension DiaryHomeCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UICollectionViewDataSource {

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return yearsCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! HomeYearCollectionViewCell
        
        var components = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: NSDate())
        var year = components
        if sectionsCount > 0 {
            if let sectionInfo = fetchedResultsController.sections![indexPath.row] as? NSFetchedResultsSectionInfo {
                println("Section info \(sectionInfo.name)")
                year = sectionInfo.name!.toInt()!
            }
        }
        
        cell.textInt = year
        cell.labelText = "\(numberToChinese(cell.textInt)) 年"
        
        // Configure the cell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var numberOfCells:Int = 1
        
        if fetchedResultsController.sections!.count != 0 {
            numberOfCells = fetchedResultsController.sections!.count
        }
        
        if (numberOfCells < 3) {
            var edgeInsets = (collectionViewWidth - ((CGFloat(numberOfCells)*itemWidth)+(CGFloat(numberOfCells)-1) * itemSpacing))/2.0
            return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
        }else{
            return UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryYearCollectionViewController") as! DiaryYearCollectionViewController
        
        
        var components = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: NSDate())
        var year = components
        if sectionsCount > 0 {
            if let sectionInfo = fetchedResultsController.sections![indexPath.row] as? NSFetchedResultsSectionInfo {
                println("Section info \(sectionInfo.name)")
                year = sectionInfo.name!.toInt()!
            }
        }
        dvc.year = year
        
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
}
