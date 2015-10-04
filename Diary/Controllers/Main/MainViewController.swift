//
//  MainViewController.swift
//  Diary
//
//  Created by zhowkevin on 15/10/5.
//  Copyright © 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

let HomeYearCollectionViewCellIdentifier = "HomeYearCollectionViewCell"
let DiaryCollectionViewCellIdentifier = "DiaryCollectionViewCell"

class MainViewController: DiaryBaseViewController {
    
    enum InterfaceType: Int {
        case Home
        case Year
        case Month
    }
    
    let animator = DiaryAnimator()

    @IBOutlet weak var titleLabel: DiaryLabel!
    
    @IBOutlet weak var composeButton: UIButton!
    
    @IBOutlet weak var subLabel: DiaryLabel!
    
    var interfaceType: InterfaceType?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var diarys = [NSManagedObject]()
    
    var fetchedResultsController : NSFetchedResultsController!
    
    var yearsCount: Int = 1
    
    var sectionsCount: Int = 0
    
    var year:Int = 0
    
    var month:Int = 1
    
    @IBOutlet weak var titleLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var subLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var subLabelCenter: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let interfaceType = interfaceType {
            print(interfaceType)
        } else {
            interfaceType = .Home
        }
        
        let yearLayout = DiaryLayout()
        collectionView.setCollectionViewLayout(yearLayout, animated: false)
        
        collectionView.registerNib(UINib(nibName: "DiaryAutoLayoutCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: DiaryCollectionViewCellIdentifier)
        
        prepareFetch()

        refetch()
        
        setupUI()
        
        let mDoubleUpRecognizer = UITapGestureRecognizer(target: self, action: "popBack")
        
        mDoubleUpRecognizer.numberOfTapsRequired = 2
        
        self.collectionView.addGestureRecognizer(mDoubleUpRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadCollectionView", name: "DiaryChangeFont", object: nil)
        
        if portrait {
            collectionView.contentInset = calInsets(true)
        } else {
            collectionView.contentInset = calInsets(false)
        }
        
        view.layoutIfNeeded()
        // Do any additional setup after loading the view.
    }
    
    func reloadCollectionView() {
        print("reloadData")
        self.collectionView.reloadData()
    }
    
    func popBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func moveToThisMonth() {
        
        let currentMonth = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: NSDate())
        
        if (diarys.count > 0){
            let diary = diarys.last as! Diary
            
            if (currentMonth >  diary.month.integerValue) {
                let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
                dvc.interfaceType = .Month
                dvc.year = diary.year.integerValue
                
                self.navigationController!.pushViewController(dvc, animated: true)
            }else{
                let dvc = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
                dvc.interfaceType = .Month
                dvc.year = diary.year.integerValue
                dvc.month = diary.month.integerValue
                
                self.navigationController!.pushViewController(dvc, animated: true)
            }
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
        
        print("Content Offset is \(collectionView.contentOffset)")
        
        let contentSizeWidth = collectionView.collectionViewLayout.collectionViewContentSize().width

        if contentSizeWidth > collectionViewWidth {
            collectionView.contentOffset = CGPointMake(collectionView.contentOffset.x + contentSizeWidth-collectionViewWidth, 0)
        }
        
        print("Content Offset is \(collectionView.contentOffset) \(contentSizeWidth)")
    }
    
    func prepareFetch() {
        if let interfaceType = interfaceType {
            
            switch interfaceType {
            case .Home:
                
                let fetchRequest = NSFetchRequest(entityName:"Diary")
                
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
                
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                    managedObjectContext: managedContext, sectionNameKeyPath: "year",
                    cacheName: nil)
            case .Year:
                let fetchRequest = NSFetchRequest(entityName:"Diary")
                fetchRequest.predicate = NSPredicate(format: "year = \(year)")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
                
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                    managedObjectContext: managedContext, sectionNameKeyPath: "month",
                    cacheName: nil)
                //3
                fetchedResultsController.delegate = self
            case .Month:
                let fetchRequest = NSFetchRequest(entityName:"Diary")
                
                print("year = \(year) AND month = \(month)")
                
                fetchRequest.predicate = NSPredicate(format: "year = \(year) AND month = \(month)")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
                
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                    managedObjectContext: managedContext, sectionNameKeyPath: "year",
                    cacheName: nil)
                
                fetchedResultsController.delegate = self
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollToCollectionViewRight()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController!.delegate = self
    }
    
    
    func refetch() {
        
        if let interfaceType = interfaceType {
            
            switch interfaceType {
            case .Home:
                homeFetch()
            case .Year:
                yearFetch()
            case .Month:
                monthFetch()
            }
            
        }

    }
    
    func monthFetch() {
        
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
    
    func homeFetch() {
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
    
    func yearFetch() {
        
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
    
    func newCompose() {
        
        let composeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DiaryComposeViewController") as! DiaryComposeViewController
        
        self.presentViewController(composeViewController, animated: true, completion: nil)
        
    }
    
    func setupUI() {
        composeButton.customButtonWith(text: "撰",  fontSize: 14.0,  width: 40.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        composeButton.addTarget(self, action: "newCompose", forControlEvents: UIControlEvents.TouchUpInside)
        
        titleLabel.config("TpldKhangXiDictTrial", labelText: "二零一五年", fontSize: 20.0, lineHeight: 5.0)
        subLabel.config(defaultFont, labelText: "\(numberToChineseWithUnit(month))月", fontSize: 16.0, lineHeight: 5.0)
        subLabel.updateLabelColor(DiaryRed)
        
        if let titleLabelSize = titleLabel.labelSize {
            titleLabelHeight.constant = titleLabelSize.height
            print(titleLabelSize.height)
        }
        
        if let subLabelSize = subLabel.labelSize {
            subLabelHeight.constant = subLabelSize.height + 1
            if portrait {
                subLabelCenter.constant = -15
            }else {
                subLabelCenter.constant = 50
            }
        }
        
        if let interfaceType = interfaceType {
            
            switch interfaceType {
            case .Home:
                titleLabel.hidden = true
                subLabel.hidden = true
                composeButton.hidden = true
                
            case .Year:
                subLabel.hidden = true
            default:
                break
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
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
                // Configure the cell
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DiaryCollectionViewCellIdentifier, forIndexPath: indexPath) as! DiaryAutoLayoutCollectionViewCell
                let diary = fetchedResultsController.objectAtIndexPath(indexPath) as! Diary
                // Configure the cell
                
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
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        

        animator.operation = operation
        return animator
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        refetch()
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        self.collectionView.reloadData()
        
        scrollToCollectionViewRight()
    }
    

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if size.height == screenRect.height {
            subLabelCenter.constant = -15
            collectionView.contentInset = calInsets(true)
        }else {
            subLabelCenter.constant = 50
            collectionView.contentInset = calInsets(false)
        }
        
        animator.newSize = size
        
        view.layoutIfNeeded()
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

}