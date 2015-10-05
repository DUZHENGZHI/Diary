//
//  DiaryDataManager.swift
//  Diary
//
//  Created by zhowkevin on 15/10/5.
//  Copyright © 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

extension MainViewController: UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    
    func moveToThisMonth() {
        
        let currentMonth = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: NSDate())
        
        if (diarys.count > 0){
            let diary = diarys.last as! Diary
            
            let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
            
            if (currentMonth >  diary.month.integerValue) {
                
                //Move To Year Beacuse Lack of currentMonth Diary
                
                dvc.interfaceType = .Year
                dvc.year = diary.year.integerValue
                
            }else{
                
                dvc.interfaceType = .Month
                dvc.year = diary.year.integerValue
                dvc.month = diary.month.integerValue
            }
            
            self.navigationController!.pushViewController(dvc, animated: true)
        }else{
            let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
            
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
            
            do {
                try managedContext.save()
                
                self.navigationController!.pushViewController(dvc, animated: true)
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let interfaceType = interfaceType {
            switch interfaceType {
            case .Home:
                return yearsCount
            case .Year:
                if fetchedResultsController.sections!.count == 0 {
                    return 1
                }else{
                    return fetchedResultsController.sections!.count
                }
            case .Month:
                return diarys.count
            }
        } else {
            
            return 0
            
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let interfaceType = interfaceType {
            switch interfaceType {
            case .Home:
                
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DiaryCollectionViewCellIdentifier, forIndexPath: indexPath) as! DiaryAutoLayoutCollectionViewCell
                
                let components = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: NSDate())
                var year = components
                if sectionsCount > 0 {
                    let sectionInfo = fetchedResultsController.sections![indexPath.row]
                    print("Section info \(sectionInfo.name)")
                    year = Int(sectionInfo.name)!
                }
                
                cell.textInt = year
                
                cell.isYear = true
                
                cell.labelText = "\(numberToChinese(cell.textInt)) 年"
                
                cell.selectCell = {
                    let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
                    
                    dvc.interfaceType = .Year
                    
                    let components = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: NSDate())
                    
                    var year = components
                    
                    if self.sectionsCount > 0 {
                        let sectionInfo = self.fetchedResultsController.sections![indexPath.row]
                        year = Int(sectionInfo.name)!
                    }
                    
                    dvc.year = year
                    
                    self.navigationController!.pushViewController(dvc, animated: true)
                }
                
                // Configure the cell
                
                return cell
                
            case .Year:
                
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DiaryCollectionViewCellIdentifier, forIndexPath: indexPath) as! DiaryAutoLayoutCollectionViewCell
                if fetchedResultsController.sections?.count == 0 {
                    
                    cell.labelText = "\(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: NSDate()))) 月"
                    
                }else{
                    
                    let sectionInfo = fetchedResultsController.sections![indexPath.row]
                    let month = Int(sectionInfo.name)
                    cell.labelText = "\(numberToChineseWithUnit(month!)) 月"
                }
                
                cell.selectCell = {
                    let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
                    dvc.interfaceType = .Month
                    if self.fetchedResultsController.sections?.count == 0 {
                        dvc.month = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: NSDate())
                    }else{
                        let sectionInfo = self.fetchedResultsController.sections![indexPath.row]
                        let month = Int(sectionInfo.name)
                        dvc.month = month!
                    }
                    dvc.year = self.year
                    self.navigationController!.pushViewController(dvc, animated: true)
                }
                
                return cell
                
            case .Month:
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DiaryCollectionViewCellIdentifier, forIndexPath: indexPath) as! DiaryAutoLayoutCollectionViewCell
                let diary = fetchedResultsController.objectAtIndexPath(indexPath) as! Diary
                
                if let title = diary.title {
                    cell.labelText = title
                }else{
                    cell.labelText = "\(numberToChineseWithUnit(NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: diary.created_at))) 日"
                }
                
                cell.selectCell = {
                    let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryViewController") as! DiaryViewController
                    
                    let diary = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Diary
                    
                    dvc.diary = diary
                    
                    self.navigationController!.pushViewController(dvc, animated: true)
                }
                
                return cell
            }
        } else {
            
            return UICollectionViewCell()
            
        }
        
    }
    
    func calInsets(portrait: Bool) -> UIEdgeInsets {
        
        var insetLeft =  (screenRect.width - collectionViewWidth)/2.0
        
        if portrait {
            insetLeft = (screenRect.width - collectionViewWidth)/2.0
        }else {
            insetLeft = (screenRect.height - collectionViewWidth)/2.0
        }
        
        var numberOfCells:Int = fetchedResultsController.sections!.count > 0 ? fetchedResultsController.sections!.count : 1
        
        if interfaceType == .Month {
            numberOfCells = self.diarys.count
        }
        
        var edgeInsets = insetLeft + (collectionViewWidth - (CGFloat(numberOfCells)*itemWidth))/2.0
        
        if (numberOfCells > collectionViewDisplayedCells) {
            
            edgeInsets = insetLeft
            
        }
        
        return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets)
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        refetch()
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        self.collectionView.reloadData()
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if size.height == screenRect.height {
            subLabelCenter.constant = -15
            collectionView.contentInset = calInsets(true)
        }else {
            subLabelCenter.constant = 50
            collectionView.contentInset = calInsets(false)
        }
        
        DiaryNavTransactionAnimator.animator.newSize = size
        
        view.layoutIfNeeded()
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
}