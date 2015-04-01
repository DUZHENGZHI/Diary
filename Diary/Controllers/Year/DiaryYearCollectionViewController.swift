//
//  DiaryYearCollectionViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/2/18.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

let reuseYearIdentifier = "YearMonthCollectionViewCell"

class DiaryYearCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    var diarys = [NSManagedObject]()
    
    var year:Int = 0
    
    var yearLabel:UILabel!
    
    var composeButton:UIButton!
    
    var fetchedResultsController : NSFetchedResultsController!
    
    var diarysGroupInMonth = [Int: Int]()
    
    var diaryProgressBar: DiaryProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        //Add year label
        setupUI()
        //2
        let fetchRequest = NSFetchRequest(entityName:"Diary")
        fetchRequest.predicate = NSPredicate(format: "year = \(year)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext, sectionNameKeyPath: "year",
            cacheName: nil)
        //3
        fetchedResultsController.delegate = self

        refetch()
        var yearLayout = DiaryLayout()
        
        yearLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        self.collectionView?.setCollectionViewLayout(yearLayout, animated: false)

        // Do any additional setup after loading the view.
    }
    
    func refetch() {
        var error: NSError? = nil
        if (!fetchedResultsController.performFetch(&error)){
            println("Error: \(error?.localizedDescription)")
        }else{
            
            var fetchedResults = fetchedResultsController.fetchedObjects as [NSManagedObject]
            if (fetchedResults.count == 0){
                NSLog("Present empty year")
            }else{
                
                diarys = fetchedResults
                for diary in diarys{
                    var diary = diary as Diary
                    
                    var date = diary.created_at
                    var components = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: diary.created_at)
                    
                    if diarysGroupInMonth[components] == nil {
                        diarysGroupInMonth[components] = 1
                    }else{
                        diarysGroupInMonth[components] = diarysGroupInMonth[components]! + 1
                    }
                    println("This day is \(diarysGroupInMonth)")
                }
            }
        }
    }
    
    func setupUI() {
        
        yearLabel = DiaryLabel(fontname: "TpldKhangXiDictTrial", labelText: "\(numberToChinese(year))年", fontSize: 20.0,lineHeight: 5.0)
        
        yearLabel.center = CGPointMake(screenRect.width - yearLabel.frame.size.width/2.0 - 15, 20 + yearLabel.frame.size.height/2.0 )
        
        self.view.addSubview(yearLabel)
        
        yearLabel.userInteractionEnabled = true
        
        var mTapUpRecognizer = UITapGestureRecognizer(target: self, action: "backToHome")
        mTapUpRecognizer.numberOfTapsRequired = 1
        yearLabel.addGestureRecognizer(mTapUpRecognizer)
        
        //Add compose button
        
        composeButton = diaryButtonWith(text: "撰",  fontSize: 14.0,  width: 40.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        composeButton.center = CGPointMake(screenRect.width - yearLabel.frame.size.width/2.0 - 15, 38 + yearLabel.frame.size.height + 26.0/2.0)
        
        composeButton.addTarget(self, action: "newCompose", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.view.addSubview(composeButton)
        //
        
        self.collectionView?.frame = CGRectMake((screenRect.width - collectionViewWidth)/2.0, (screenRect.height - itemHeight)/2.0, collectionViewWidth, itemHeight)
        
        self.collectionView?.delegate = self
        
        diaryProgressBar = DiaryProgress(frame: CGRectMake(0, 0, collectionViewWidth, 8.0))
        diaryProgressBar.center = CGPointMake(self.collectionView!.center.x, self.collectionView!.center.y + self.collectionView!.frame.size.height/2.0 + 30.0)
        diaryProgressBar.alpha = 0.0
        self.view.addSubview(diaryProgressBar)
   
    }
    
    func backToHome(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func newCompose() {

        var diary = findLastDayDiary()
        
        var composeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryComposeViewController") as DiaryComposeViewController
        
        if (diary != nil){
            println("Find \(diary?.created_at)")
            composeViewController.diary = diary
        }
        
        self.presentViewController(composeViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        NSLog("Year did show")
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
        
        if diarysGroupInMonth.keys.array.count == 0 {
            return 1
        }else{
            return diarysGroupInMonth.keys.array.count
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseYearIdentifier, forIndexPath: indexPath) as DiaryCollectionViewCell
        if diarysGroupInMonth.keys.array.count == 0 {
            
            println("No Month")
            
            cell.labelText = "\(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate()))) 月"

        }else{
            
            var month = diarysGroupInMonth.keys.array[indexPath.row]
            // Configure the cell
            cell.labelText = "\(numberToChineseWithUnit(month)) 月"
            
            
        }
        
        return cell

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var numberOfCells:Int = 1
        if diarysGroupInMonth.keys.array.count != 0 {
            numberOfCells = diarysGroupInMonth.keys.array.count
        }
        
        if (numberOfCells < 3) {
            var edgeInsets = (collectionViewWidth - ((CGFloat(numberOfCells)*itemWidth)+(CGFloat(numberOfCells)-1) * itemSpacing))/2.0
            return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
        }else{
            return UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryMonthDayCollectionViewController") as DiaryMonthDayCollectionViewController
        
        if diarysGroupInMonth.keys.array.count == 0 {
            dvc.month = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
        }else{
            dvc.month = diarysGroupInMonth.keys.array[indexPath.row]
        }
        dvc.year = year

        //        dvc.collectionView?.dataSource = collectionView.dataSource
        
        self.navigationController!.pushViewController(dvc, animated: true)
        
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
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        refetch()
        self.collectionView?.reloadData()
        
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        self.collectionView!.contentOffset = CGPointMake(self.collectionView!.collectionViewLayout.collectionViewContentSize().width-collectionViewWidth, 0)
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
