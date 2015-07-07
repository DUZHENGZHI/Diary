//
//  DiaryCloud.swift
//  Diary
//
//  Created by kevinzhow on 15/5/2.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class DiaryCloud: NSObject {
    static let sharedInstance = DiaryCloud()
    
    var fetchedResultsController : NSFetchedResultsController!
    
    override init() {
        
        super.init()
        
        let fetchRequest = NSFetchRequest(entityName:"Diary")
        
        let entity =  NSEntityDescription.entityForName("Diary", inManagedObjectContext: managedContext)
        
        var error: NSError?
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext, sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        startFetch()
        
    }
    
    func startFetch() {
        
        var error: NSError? = nil
        if (!fetchedResultsController.performFetch(&error)){
            println("Error: \(error?.localizedDescription)")
        }else{
            
            var fetchedResults = fetchedResultsController.fetchedObjects as! [Diary]
            
            
            println("All Diary is \(fetchedResults.count)")

        }
    }
    
    func startSync() {
        
        println("New sycn")
        
        var allRecords  = fetchedResultsController.fetchedObjects as! [Diary]
        
        for record in allRecords {
            if let recordID = record.id {
                
                println(record)
                
                println("No need add ID")

            } else {
                
                record.id = randomStringWithLength(32) as String
                
                if  let title = record.title {
                    saveNewRecord(record)
                }

            }
        }
        
        managedContext.save(nil)
        
        fetchCloudRecords { (records) -> Void in
            if let records = records {
                for fetchRecord in records {
                    if let diaryID = fetchRecord.objectForKey("id") as? String {
                        if let diary = fetchDiaryByID(diaryID) {
                            println("No need to do thing")
                        } else {
                            println("Create Diary With CKRecords")
                            saveDiaryWithCKRecord(fetchRecord)
                        }
                    }
                }
            }
        }
    }
}

func saveDiaryWithCKRecord(record: CKRecord) {
    let entity =  NSEntityDescription.entityForName("Diary", inManagedObjectContext: managedContext)

    if let ID = record.objectForKey("id") as? String,
        Content = record.objectForKey("Content") as? String,
        Location = record.objectForKey("Location") as? String,
        Title = record.objectForKey("Title") as? String,
        Date = record.objectForKey("Created_at") as? NSDate {
            
            let newdiary = Diary(entity: entity!,
                insertIntoManagedObjectContext:managedContext)
            
            newdiary.id = ID
            
            newdiary.content = Content
            
            newdiary.location = Location
            
            newdiary.title = Title
            
            newdiary.updateTimeWithDate(Date)
    }
    
    managedContext.save(nil)
}

func fetchDiaryByID(id: String) -> Diary? {
    
    let fetchRequest = NSFetchRequest(entityName:"Diary")
    fetchRequest.predicate = NSPredicate(format: "id = %@", id)
    
    var error: NSError?
    
    let fetchedResults =
    managedContext.executeFetchRequest(fetchRequest,
        error: &error) as? [Diary]
    
    if let results = fetchedResults {
        return results.first
    } else {
        println("Could not fetch \(error), \(error!.userInfo)")
        return nil
    }

}

extension DiaryCloud: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        startSync()
    }
}