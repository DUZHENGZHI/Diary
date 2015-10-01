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

class DiaryYearCollectionViewController: DiaryBaseCollecitionViewController{
    
    var diarys = [NSManagedObject]()
    
    var year:Int = 0
    
    var yearLabel:UILabel!
    
    var composeButton:UIButton!
    
    var fetchedResultsController : NSFetchedResultsController!
    
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
            managedObjectContext: managedContext, sectionNameKeyPath: "month",
            cacheName: nil)
        //3
        fetchedResultsController.delegate = self

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
                NSLog("Present empty year")
            }else{
                
                diarys = fetchedResults
            }
            
        } catch _ {
            
        }

    }
    
    func setupUI() {
        
        yearLabel = DiaryLabel(fontname: "TpldKhangXiDictTrial", labelText: "\(numberToChinese(year))年", fontSize: 20.0,lineHeight: 5.0)
        
        yearLabel.center = CGPointMake(screenRect.width - yearLabel.frame.size.width/2.0 - 15, 20 + yearLabel.frame.size.height/2.0 )
        
        self.view.addSubview(yearLabel)
        
        yearLabel.userInteractionEnabled = true
        
        let mTapUpRecognizer = UITapGestureRecognizer(target: self, action: "backToHome")
        mTapUpRecognizer.numberOfTapsRequired = 1
        yearLabel.addGestureRecognizer(mTapUpRecognizer)
        
        //Add compose button
        
        composeButton = diaryButtonWith(text: "撰",  fontSize: 14.0,  width: 40.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        
        composeButton.center = CGPointMake(screenRect.width - yearLabel.frame.size.width/2.0 - 15, 38 + yearLabel.frame.size.height + 26.0/2.0)
        
        composeButton.addTarget(self, action: "newCompose", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.view.addSubview(composeButton)
        //
        
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

        let diary = findLastDayDiary()
        
        let composeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryComposeViewController") as! DiaryComposeViewController
        
        if (diary != nil){
            print("Find \(diary?.created_at)")
            composeViewController.diary = diary
        }
        
        self.presentViewController(composeViewController, animated: true, completion: nil)
        
    }
    
    
    func scrollToCollectionViewRight() {
        self.collectionView!.contentOffset = CGPointMake(self.collectionView!.collectionViewLayout.collectionViewContentSize().width-collectionViewWidth-collectionViewLeftInsets*2, 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        NSLog("Year did show")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DiaryYearCollectionViewController: UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        
        if fetchedResultsController.sections!.count == 0 {
            return 1
        }else{
            return fetchedResultsController.sections!.count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseYearIdentifier, forIndexPath: indexPath) as! DiaryCollectionViewCell
        if fetchedResultsController.sections?.count == 0 {
            
            cell.labelText = "\(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: NSDate()))) 月"
            
        }else{
            
            let sectionInfo = fetchedResultsController.sections![indexPath.row] 
            let month = Int(sectionInfo.name)
            cell.labelText = "\(numberToChineseWithUnit(month!)) 月"
        }
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let numberOfCells:Int = fetchedResultsController.sections!.count > 0 ? fetchedResultsController.sections!.count : 1
        
        var edgeInsets = collectionViewLeftInsets + (collectionViewWidth - (CGFloat(numberOfCells)*itemWidth))/2.0
        
        if (numberOfCells > collectionViewDisplayedCells) {
            
            edgeInsets = collectionViewLeftInsets
            
        }
        
        print("Left inset is \(edgeInsets)")
        
        return UIEdgeInsetsMake(collectionViewTopInset, edgeInsets, collectionViewTopInset, edgeInsets);
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryMonthDayCollectionViewController") as! DiaryMonthDayCollectionViewController
        
        if fetchedResultsController.sections?.count == 0 {
            dvc.month = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: NSDate())
        }else{
            let sectionInfo = fetchedResultsController.sections![indexPath.row] 
            let month = Int(sectionInfo.name)
            dvc.month = month!
        }
        dvc.year = year
        
        //        dvc.collectionView?.dataSource = collectionView.dataSource
        
        self.navigationController!.pushViewController(dvc, animated: true)
        
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let length = scrollView.contentSize.width - collectionViewWidth
        let offset = scrollView.contentOffset.x
        
        let progess = offset/length
        
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
        
        scrollToCollectionViewRight()
    }
}
