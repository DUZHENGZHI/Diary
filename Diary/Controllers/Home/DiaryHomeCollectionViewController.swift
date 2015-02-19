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
    
    var years = 1
    
    var diarysGroupInYear = [Int: Int]()
    
    var sourceCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"Diary")
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            diarys = results
        } else {
            NSLog("Could not fetch \(error), \(error!.userInfo)")
        }
        
        for diary in diarys {
            var date = diary.valueForKey("created_at") as! NSDate
            var components = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: date)
            
            if diarysGroupInYear[components] == nil {
                diarysGroupInYear[components] = 1
            }else{
                diarysGroupInYear[components] = diarysGroupInYear[components]! + 1
            }
        }
        
        if  diarysGroupInYear.keys.array.count == 0 {
            var components = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: NSDate.new())
            diarysGroupInYear[components] = 1
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //Dont use this if you are using storyboard
//        self.collectionView!.registerClass(HomeYearCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        var yearLayout = DiaryLayout.new()

        yearLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView?.setCollectionViewLayout(yearLayout, animated: false)

        // Do any additional setup after loading the view.
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
        
        NSLog("Show cell")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! HomeYearCollectionViewCell
        
        var yearText = diarysGroupInYear.keys.array[indexPath.row]
        
        cell.yearText = "二零一五年"

        // Configure the cell
    
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        var screenRect = UIScreen.mainScreen().bounds
        var screenWidth = screenRect.size.width
        var screenHeight = screenRect.size.height
        
        
        var numberOfCells = screenWidth / 20.0
        var edgeInsets = (CGFloat(screenWidth) - CGFloat(self.diarysGroupInYear.keys.array.count) * 20.0) / 2.0
        

        var itemHeight = 150.0
        
        
        return UIEdgeInsetsMake((screenHeight - 150.0) / 2.0 , edgeInsets, 0, edgeInsets);
    }

    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        NSLog("Push view controller")
        
        var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryYearCollectionViewController") as! DiaryYearCollectionViewController
        
//        dvc.collectionView?.dataSource = collectionView.dataSource
        
        self.sourceCollectionView = collectionView
        
        self.navigationController?.pushViewController(dvc, animated: true)
        
        NSLog("Pushed")
        
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (fromVC == self && operation == UINavigationControllerOperation.Push) {

            NSLog("Do animtion")
            var animator = DiaryAnimator()
            animator.fromCollectionView = self.sourceCollectionView
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
