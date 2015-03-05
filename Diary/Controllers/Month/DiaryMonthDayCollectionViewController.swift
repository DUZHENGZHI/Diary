//
//  DiaryMonthDayCollectionViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/3/6.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

let reuseMonthDayCellIdentifier = "MonthDayCollectionViewCell"

class DiaryMonthDayCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    var diarys = [NSManagedObject]()
    
    var year:Int = 0
    
    var month:Int = 1
    
    var yearLabel:DiaryLabel!
    
    var monthLabel:DiaryLabel!
    
    var monthLabelContainer: UIView!
    
    var composeButton:UIButton!
    
    var fetchedResultsController : NSFetchedResultsController!
    
    var diarysGroupInMonth = [Int: Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        //Add year label
        
        yearLabel = DiaryLabel(fontname: "TpldKhangXiDictTrial", labelText: "二零一五年", fontSize: 16.0,lineHeight: 5.0)
        
        yearLabel.center = CGPointMake(screenRect.width - yearLabel.frame.size.width/2.0 - 15, 20 + yearLabel.frame.size.height/2.0 )
        
        self.view.addSubview(yearLabel)
        
        //Add compose button
        
        composeButton = diaryButtonWith(text: "撰",  fontSize: 14.0,  width: 26.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        composeButton.center = CGPointMake(screenRect.width - yearLabel.frame.size.width/2.0 - 15, 35 + yearLabel.frame.size.height + 26.0/2.0)
        
        composeButton.addTarget(self, action: "newCompose", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.view.addSubview(composeButton)
        //
        monthLabelContainer = UIView(frame: CGRectMake(0, 0, 0, 0))
        monthLabelContainer.backgroundColor = UIColor.whiteColor()
        monthLabel = DiaryLabel(fontname: "Wyue-GutiFangsong-NC", labelText: "三月", fontSize: 16.0,lineHeight: 5.0)
        
        monthLabel.updateLabelColor(DiaryRed)
        

        monthLabelContainer.addSubview(monthLabel)
        self.view.addSubview(monthLabelContainer)
        
        //
        
        
        self.navigationController?.delegate = self
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"Diary")
        
        //        var beginDay = "01/01/\(year)"
        //        var endDay = "12/31/\(year)"
        //        var formatter = NSDateFormatter.new()
        //        formatter.dateFormat = "MM/dd/yyyy"
        //
        //        var beginDate = formatter.dateFromString(beginDay)
        //        var endDate = formatter.dateFromString(endDay)
        
        fetchRequest.predicate = NSPredicate(format: "year = \(year) AND month = \(month)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext, sectionNameKeyPath: "year",
            cacheName: nil)
        //3
        var error: NSError? = nil
        if (!fetchedResultsController.performFetch(&error)){
            println("Error: \(error?.localizedDescription)")
        }
        
        var fetchedResults = fetchedResultsController.fetchedObjects as! [NSManagedObject]
        diarys = fetchedResults
        print("This month have \(diarys.count) \n")
        var monthLayout = DiaryLayout.new()
        
        monthLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal

        self.collectionView?.setCollectionViewLayout(monthLayout, animated: false)

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseMonthDayCellIdentifier)

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
        return diarys.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        // Configure the cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseMonthDayCellIdentifier, forIndexPath: indexPath) as! DiaryCollectionViewCell
        var diary = fetchedResultsController.objectAtIndexPath(indexPath) as! Diary
        // Configure the cell

        cell.labelText = "三十一日"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        
        var numberOfCells = screenRect.width / 20.0
        var edgeInsets = (CGFloat(screenRect.width) - CGFloat(3) * 20.0 - CGFloat(2) * 30.0) / 2.0
        print("\(edgeInsets) for section ")

        
        monthLabelContainer.frame = CGRectMake(screenRect.width - edgeInsets,(screenRect.height - 150.0) / 2.0 , edgeInsets, 150.0)
        
        monthLabel.center = CGPointMake(edgeInsets - monthLabel.frame.size.width/2.0 - 15.0, monthLabel.frame.size.height/2.0)
        var itemHeight = 150.0
        
        return UIEdgeInsetsMake((screenRect.height - 150.0) / 2.0 , edgeInsets, 0, edgeInsets);
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
