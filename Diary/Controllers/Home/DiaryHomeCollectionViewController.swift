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
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext, sectionNameKeyPath: "year",
            cacheName: nil)
        
        refetch()
        
        let yearLayout = DiaryLayout()
        yearLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView?.setCollectionViewLayout(yearLayout, animated: false)

        // Do any additional setup after loading the view.
    }
    
    
    func refetch() {
        
        do {
            try fetchedResultsController.performFetch()
            let fetchedResults = fetchedResultsController.fetchedObjects as! [NSManagedObject]
            
            if (fetchedResults.count == 0){
                print("Present empty year")
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
        } catch _ {
            
        }
    }
    
    func moveToThisMonth() {
        
        let currentMonth = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: NSDate())
        
        if (diarys.count > 0){
            let diary = diarys.last as! Diary
            
            if (currentMonth >  diary.month.integerValue) {
                let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryYearCollectionViewController") as! DiaryYearCollectionViewController
                
                dvc.year = diary.year.integerValue
                
                self.navigationController!.pushViewController(dvc, animated: true)
            }else{
                let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryMonthDayCollectionViewController") as! DiaryMonthDayCollectionViewController
                
                dvc.year = diary.year.integerValue
                dvc.month = diary.month.integerValue
                
                self.navigationController!.pushViewController(dvc, animated: true)
            }
        }else{
            let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryMonthDayCollectionViewController") as! DiaryMonthDayCollectionViewController
            let filePath = NSBundle.mainBundle().pathForResource("poem", ofType: "json")
            let JSONData = try? NSData(contentsOfFile: filePath!, options: NSDataReadingOptions.MappedRead)
            let jsonObject = (try! NSJSONSerialization.JSONObjectWithData(JSONData!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            var poemsCollection = jsonObject.valueForKey("poems") as! [String: AnyObject]
            
            let poems = currentLanguage == "ja" ?  (poemsCollection["ja"] as! NSArray) : ( poemsCollection["cn"] as! NSArray)
            
            for poem in poems{
                
                let poem =  poem as! NSDictionary
                let entity =  NSEntityDescription.entityForName("Diary", inManagedObjectContext: managedContext)
                
                let newdiary = Diary(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                
                newdiary.id = randomStringWithLength(32) as String
                
                newdiary.content = poem.valueForKey("content") as! String
                newdiary.title = poem.valueForKey("title") as? String
                newdiary.location = poem.valueForKey("location") as? String
                
                newdiary.updateTimeWithDate(NSDate())
                dvc.month = newdiary.month.integerValue
                dvc.year = newdiary.year.integerValue

            }
            
            self.navigationController!.pushViewController(dvc, animated: true)
            
            var error: NSError?
            do {
                try managedContext.save()
            } catch let error1 as NSError {
                error = error1
                print("Could not save \(error), \(error?.userInfo)")
            }
        }
        
    }
    
    func scrollToCollectionViewRight() {
        self.collectionView!.contentOffset = CGPointMake(self.collectionView!.collectionViewLayout.collectionViewContentSize().width-collectionViewWidth-collectionViewLeftInsets*2, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension DiaryHomeCollectionViewController: UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
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
        return yearsCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> HomeYearCollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! HomeYearCollectionViewCell
        
        let components = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: NSDate())
        var year = components
        if sectionsCount > 0 {
            let sectionInfo = fetchedResultsController.sections![indexPath.row]
            print("Section info \(sectionInfo.name)")
            year = Int(sectionInfo.name)!
        }
        
        cell.textInt = year
        cell.labelText = "\(numberToChinese(cell.textInt)) 年"
        
        // Configure the cell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let numberOfCells:Int = fetchedResultsController.sections!.count > 0 ? fetchedResultsController.sections!.count : 1
        
        var edgeInsets = collectionViewLeftInsets + (collectionViewWidth - (CGFloat(numberOfCells)*itemWidth))/2.0
        
        if (numberOfCells > collectionViewDisplayedCells) {
            
            edgeInsets = collectionViewLeftInsets
            
        }
        
        return UIEdgeInsetsMake(collectionViewTopInset, edgeInsets, collectionViewTopInset, edgeInsets);
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryYearCollectionViewController") as! DiaryYearCollectionViewController
        
        
        let components = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: NSDate())
        var year = components
        if sectionsCount > 0 {
            let sectionInfo = fetchedResultsController.sections![indexPath.row]
            print("Section info \(sectionInfo.name)")
            year = Int(sectionInfo.name)!
        }
        dvc.year = year
        
        self.navigationController!.pushViewController(dvc, animated: true)
        
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = DiaryAnimator()
        animator.operation = operation
        return animator
    }
}
