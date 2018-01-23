//
//  DiaryFetchManager.swift
//  Diary
//
//  Created by zhowkevin on 15/10/5.
//  Copyright © 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

extension MainViewController {
    
    func prepareFetch() {
        
        refetch()
    
        if let interfaceType = interfaceType {
            if interfaceType == .Year {
                moveToThisMonth()
            }
        }
    }
    
    func refetch() {
        
        if let interfaceType = interfaceType {
            
            switch interfaceType {
            case .Year:
                yearsFetch()
            case .Month:
                yearMonthsFetch()
            case .Day:
                monthDaysFetch()
            }
        }
    }
    
    func monthDaysFetch() {
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Diary")
            
            debugPrint("year = \(year) AND month = \(month)")
            
            fetchRequest.predicate = NSPredicate(format: "year = \(year) AND month = \(month)")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
            if let managedContext = DiaryCoreData.sharedInstance.managedContext {
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: managedContext, sectionNameKeyPath: "year",
                                                                      cacheName: nil)
                
                fetchedResultsController.delegate = self
            }
            
            try fetchedResultsController.performFetch()
            
            let fetchedResults = fetchedResultsController.fetchedObjects as! [NSManagedObject]
            
            if (fetchedResults.count == 0){
                NSLog("Present empty year and Month")
            }
            
            diarys = fetchedResults
            
        } catch let error as NSError {
            print("Fetch Month Error \(error.description)")
        }
        
    }
    
    func yearsFetch() {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Diary")
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
            if let managedContext = DiaryCoreData.sharedInstance.managedContext {
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: managedContext, sectionNameKeyPath: "year",
                                                                      cacheName: nil)
            }
            
            try fetchedResultsController.performFetch()
            
            let fetchedResults = fetchedResultsController.fetchedObjects as! [NSManagedObject]
            
            if (fetchedResults.count == 0){
                debugPrint("Present empty home")
            }else{
                
                if let sectionsCount = fetchedResultsController.sections?.count {
                    
                    yearsCount = sectionsCount
                    diarys = fetchedResults
                    
                } else {
                    
                    sectionsCount = 0
                    yearsCount = 1
                }
            }

        } catch let error as NSError {
            print("Fetch Home Error \(error.description)")
        }
    }
    
    func yearMonthsFetch() {
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Diary")
            fetchRequest.predicate = NSPredicate(format: "year = \(year)")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
            if let managedContext = DiaryCoreData.sharedInstance.managedContext {
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: managedContext, sectionNameKeyPath: "month",
                                                                      cacheName: nil)
                fetchedResultsController.delegate = self
            }
            try fetchedResultsController.performFetch()
            
            let fetchedResults = fetchedResultsController.fetchedObjects as! [NSManagedObject]
            if (fetchedResults.count == 0){
                NSLog("Present empty year")
            }
            diarys = fetchedResults
        } catch let error as NSError {
            print("Fetch Year Error \(error.description)")
        }
    }
    
}
