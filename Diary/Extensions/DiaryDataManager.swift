//
//  DiaryDataManager.swift
//  Diary
//
//  Created by zhowkevin on 15/10/5.
//  Copyright © 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let interfaceType = interfaceType {
            switch interfaceType {
            case .Home:
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCellIdentifier, for: indexPath as IndexPath) as! DiaryAutoLayoutCollectionViewCell
                
                let components = NSCalendar.current.component(Calendar.Component.year, from: NSDate() as Date)
                var year = components
                
                if let sectionInfo = fetchedResultsController.sections?[safe: indexPath.row] {
                    debugPrint("Section info \(sectionInfo.name)")
                    year = Int(sectionInfo.name)!
                }
                
                cell.textInt = year
                
                cell.isYear = true
                
                cell.labelText = "\(numberToChinese(number: cell.textInt)) 年"
                
                cell.selectCell = { [weak self] in
                    
                    if let strongSelf = self {
                        let dvc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                        
                        dvc.interfaceType = .Year
                        
                        let components = NSCalendar.current.component(Calendar.Component.year, from: Date())
                        
                        var year = components
                        
                        if let sectionInfo = strongSelf.fetchedResultsController.sections?[safe: indexPath.row], let tempYear = Int(sectionInfo.name) {
                            year = tempYear
                        }
                        
                        dvc.year = year
                        
                        strongSelf.navigationController!.pushViewController(dvc, animated: true)
                    }
                    
                }
                
                // Configure the cell
                
                return cell
                
            case .Year:
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCellIdentifier, for: indexPath) as! DiaryAutoLayoutCollectionViewCell
                
                if let sectionInfo = fetchedResultsController.sections?[safe: indexPath.row] {
                    let month = Int(sectionInfo.name)
                    cell.labelText = "\(numberToChineseWithUnit(number: month!)) 月"
                } else {
                    cell.labelText = "\(numberToChineseWithUnit(number: NSCalendar.current.component(Calendar.Component.month, from: Date()))) 月"
                }
                
                cell.selectCell = { [weak self] in
                    if let strongSelf = self {
                        let dvc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                        dvc.interfaceType = .Month
                        
                        if let sectionInfo = strongSelf.fetchedResultsController.sections?[safe: indexPath.row], let month = Int(sectionInfo.name) {
                            dvc.month = month
                        } else {
                            dvc.month = NSCalendar.current.component(Calendar.Component.month, from: Date())
                        }
                        
                        dvc.year = strongSelf.year
                        strongSelf.navigationController!.pushViewController(dvc, animated: true)
                    }
                    
                }
                
                return cell
                
            case .Month:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCellIdentifier, for: indexPath) as! DiaryAutoLayoutCollectionViewCell
                
                if let diary = fetchedResultsController.object(at: indexPath) as? Diary {
                    
                    if let title = diary.title {
                        cell.labelText = title
                    }else{
                        cell.labelText = "\(numberToChineseWithUnit(number: NSCalendar.current.component(Calendar.Component.day, from: diary.created_at as Date))) 日"
                    }
                    
                    cell.selectCell = { [weak self] in
                        if let strongSelf = self {
                            let dvc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "DiaryViewController") as! DiaryViewController
                            dvc.diary = diary
                            strongSelf.navigationController!.pushViewController(dvc, animated: true)
                        }
                    }
                }
                
                return cell
            }
        } else {
            
            return UICollectionViewCell()
            
        }
        
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    
    func moveToThisMonth() {
        
        let currentMonth = NSCalendar.current.component(Calendar.Component.month, from: NSDate() as Date)
        
        if (diarys.count > 0){
            let diary = diarys.last as! Diary
            
            let dvc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            
            if (currentMonth >  diary.month.intValue) {
                
                //Move To Year Beacuse Lack of currentMonth Diary
                
                dvc.interfaceType = .Year
                dvc.year = diary.year.intValue
                
            }else{
                
                dvc.interfaceType = .Month
                dvc.year = diary.year.intValue
                dvc.month = diary.month.intValue
            }
            
            self.navigationController!.pushViewController(dvc, animated: true)
        }else{
            
            let dvc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            
            let filePath = Bundle.main.path(forResource: "poem", ofType: "json")
            let JSONData = try? NSData(contentsOfFile: filePath!, options: NSData.ReadingOptions.mappedRead)
            let jsonObject = (try! JSONSerialization.jsonObject(with: JSONData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            var poemsCollection = jsonObject.value(forKey: "poems") as! [String: AnyObject]
            
            let poems = currentLanguage == "ja" ?  (poemsCollection["ja"] as! NSArray) : ( poemsCollection["cn"] as! NSArray)
            if let managedContext = DiaryCoreData.sharedInstance.managedContext {
                for poem in poems{
                    
                    let poem =  poem as! NSDictionary
                    let entity =  NSEntityDescription.entity(forEntityName: "Diary", in: managedContext)
                    let diaryID = poem.value(forKey: "id") as! String
                    
                    if let _ = fetchDiaryByID(id: diaryID) {
                        return
                    }
                    
                    let newdiary = Diary(entity: entity!,
                                         insertInto:managedContext)
                    
                    newdiary.id = diaryID
                    newdiary.content = poem.value(forKey: "content") as! String
                    newdiary.title = poem.value(forKey: "title") as? String
                    newdiary.location = poem.value(forKey: "location") as? String
                    
                    newdiary.updateTimeWithDate(date: NSDate())
                    
                    dvc.interfaceType = .Month
                    dvc.month = newdiary.month.intValue
                    dvc.year = newdiary.year.intValue
                    
                }
                
                do {
                    try managedContext.save()
                    
                    self.navigationController!.pushViewController(dvc, animated: true)
                } catch let error as NSError {
                    debugPrint("Could not save \(error), \(error.userInfo)")
                }
            }
        }
        
    }
    
    func calInsets(portrait: Bool, forSize size: CGSize) -> UIEdgeInsets {
        
        let insetLeft = (size.width - collectionViewWidth)/2.0
        
        var numberOfCells:Int = fetchedResultsController.sections!.count > 0 ? fetchedResultsController.sections!.count : 1
        
        if interfaceType == .Month {
            numberOfCells = self.diarys.count
        }
        
        var edgeInsets: CGFloat = 0
        
        if (numberOfCells >= collectionViewDisplayedCells) {
            
            edgeInsets = insetLeft
            
        } else {
            edgeInsets = insetLeft + (collectionViewWidth - (CGFloat(numberOfCells)*itemWidth))/2.0
        }
        
        debugPrint(edgeInsets)
        
        return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets)
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        self.refetch()
        
        self.collectionView.reloadData()
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        self.resetCollectionView()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DiaryChange"), object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        debugPrint(size)
        
        if portrait {
            self.collectionView.contentInset = calInsets(portrait: true, forSize: size)
        }else {
            self.collectionView.contentInset = calInsets(portrait: false, forSize: size)
        }
        
        if size.height < 480 {
            self.subLabelCenter.constant = 50
        } else {
            self.subLabelCenter.constant = -15
        }
        
        self.collectionView.contentOffset = CGPoint(x: -collectionView.contentInset.left, y: 0)
        
        if let layout = self.collectionView.collectionViewLayout as? DiaryLayout {
            layout.collectionViewLeftInsetsForLayout = self.collectionView.contentInset.left
        }
        
        DiaryNavTransactionAnimator.animator.newSize = size
        
        view.layoutIfNeeded()
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
}
