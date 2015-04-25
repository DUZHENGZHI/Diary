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


class DiaryMonthDayCollectionViewController: DiaryBaseCollecitionViewController,UICollectionViewDelegateFlowLayout , NSFetchedResultsControllerDelegate{
    
    var diarys = [NSManagedObject]()
    
    var year:Int = 0
    
    var month:Int = 1
    
    var yearLabel:DiaryLabel!
    
    var monthLabel:DiaryLabel!
    
    var composeButton:UIButton!
    
    var fetchedResultsController : NSFetchedResultsController!
    
    var diarysGroupInMonth = [Int: Int]()
    
    var diaryProgressBar: DiaryProgress!
    
    var scrolledToBottom: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        //Add year label
        self.view.backgroundColor = UIColor.whiteColor()

        setUpUI()
        
        updateFetch()
        
        var monthLayout = DiaryLayout()
        
        monthLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal

        self.collectionView?.setCollectionViewLayout(monthLayout, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFetch", name: "CoreDataDidUpdated", object: nil)

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseMonthDayCellIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func updateFetch() {
        //2
        let fetchRequest = NSFetchRequest(entityName:"Diary")
        
        println("year = \(year) AND month = \(month)")
        
        fetchRequest.predicate = NSPredicate(format: "year = \(year) AND month = \(month)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext, sectionNameKeyPath: "year",
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        //3
        var error: NSError? = nil
        if (!fetchedResultsController.performFetch(&error)){
            println("Error: \(error?.localizedDescription)")
        }
        
        refetch()
    }
    
    func refetch() {
        var fetchedResults = fetchedResultsController.fetchedObjects as! [NSManagedObject]
        diarys = fetchedResults
        print("This month have \(diarys.count) \n")
    }
    
    func setUpUI(){
        
        yearLabel = DiaryLabel(fontname: "TpldKhangXiDictTrial", labelText: "\(numberToChinese(year))年", fontSize: 20.0,lineHeight: 5.0)
        
        yearLabel.center = CGPointMake(screenRect.width - yearLabel.frame.size.width/2.0 - 15, 20 + yearLabel.frame.size.height/2.0 )
        
        yearLabel.userInteractionEnabled = true
        
        self.view.addSubview(yearLabel)
        
        var mTapUpRecognizer = UITapGestureRecognizer(target: self, action: "backToYear")
        mTapUpRecognizer.numberOfTapsRequired = 1
        yearLabel.addGestureRecognizer(mTapUpRecognizer)
        
        //Add compose button
        
        composeButton = diaryButtonWith(text: "撰",  fontSize: 14.0,  width: 40.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        composeButton.center = CGPointMake(yearLabel.center.x, 38 + yearLabel.frame.size.height + 26.0/2.0)
        
        composeButton.addTarget(self, action: "newCompose", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.view.addSubview(composeButton)
        //
        monthLabel = DiaryLabel(fontname: defaultFont, labelText: "\(numberToChineseWithUnit(month)) 月", fontSize: 16.0,lineHeight: 5.0)
        monthLabel.frame = CGRectMake(screenRect.width - 15.0 - monthLabel.frame.size.width, (screenRect.height - 150)/2.0, monthLabel.frame.size.width, monthLabel.frame.size.height)
        
        monthLabel.center = CGPointMake(composeButton.center.x, monthLabel.center.y + 28)
        
        monthLabel.updateLabelColor(DiaryRed)
        monthLabel.userInteractionEnabled = true
        
        var mmTapUpRecognizer = UITapGestureRecognizer(target: self, action: "backToYear")
        mmTapUpRecognizer.numberOfTapsRequired = 1
        monthLabel.addGestureRecognizer(mmTapUpRecognizer)
        
        
        self.view.addSubview(monthLabel)
        self.collectionView?.frame = CGRectMake((screenRect.width - collectionViewWidth)/2.0, (screenRect.height - itemHeight)/2.0, collectionViewWidth, itemHeight)
        //
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView!.delegate = self
        
        diaryProgressBar = DiaryProgress(frame: CGRectMake(0, 0, collectionViewWidth, 8.0))
        diaryProgressBar.center = CGPointMake(self.collectionView!.center.x, self.collectionView!.center.y + self.collectionView!.frame.size.height/2.0 + 30.0)
        diaryProgressBar.alpha = 0.0
        self.view.addSubview(diaryProgressBar)
    
    }
    
    override func viewDidLayoutSubviews() {
        if (!scrolledToBottom){
            self.collectionView!.contentOffset = CGPointMake(self.collectionView!.collectionViewLayout.collectionViewContentSize().width-collectionViewWidth, 0)
            scrolledToBottom = true
        }
    }
    
    
    func backToYear(){
        self.navigationController!.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newCompose() {
        
        var composeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryComposeViewController") as! DiaryComposeViewController
        
        self.presentViewController(composeViewController, animated: true, completion: nil)
        
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

        if let title = diary.title {
            cell.labelText = title
        }else{
            cell.labelText = "\(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitDay, fromDate: diary.created_at))) 日"
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var numberOfCells:Int = self.diarys.count
        if (numberOfCells < 3) {
            var edgeInsets = (collectionViewWidth - ((CGFloat(numberOfCells)*itemWidth)+(CGFloat(numberOfCells)-1) * itemSpacing))/2.0
            return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
        }else{
            return UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryViewController") as! DiaryViewController
        
        var diary = fetchedResultsController.objectAtIndexPath(indexPath) as! Diary

        dvc.diary = diary
        
        self.navigationController!.pushViewController(dvc, animated: true)
        
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        println("Diarys changed")

        refetch()
        
        self.collectionView?.reloadData()
        
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        self.collectionView!.contentOffset = CGPointMake(self.collectionView!.collectionViewLayout.collectionViewContentSize().width-collectionViewWidth, 0)
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var length = scrollView.contentSize.width - collectionViewWidth
        var offset = scrollView.contentOffset.x
        
        var progess = offset/length
        
        diaryProgressBar.progress = progess
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.diaryProgressBar.alpha = 1.0
            }, completion: nil)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        UIView.animateWithDuration(0.8, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.diaryProgressBar.alpha = 0.0
                
            }, completion: nil)
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
