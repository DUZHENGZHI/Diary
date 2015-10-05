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
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext, sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
    }
    
    func startFetch() {
        
        do {
            try fetchedResultsController.performFetch()
            let fetchedResults = fetchedResultsController.fetchedObjects as! [Diary]
            print("All Diary is \(fetchedResults.count)")
            startSync()
        } catch _ {
            
        }
    }
    
    func startSync() {
        
        print("New sycn")
        
        let allRecords  = fetchedResultsController.fetchedObjects as! [Diary]
        
        for record in allRecords {
            if let recordID = record.id {
                
                fetchCloudRecordWithID(recordID, complete: { (OldRecord) -> Void in
                    
                    if let _ = OldRecord {
//                        updateRecord(record, OldRecord)
//                        print("Already Have")
                    } else {
                        if let _ = record.title {
                            saveNewRecord(record)
                        }
                    }
                    
                })
                
            } else {
                
                record.id = randomStringWithLength(32) as String
                
                if  let _ = record.title {
                    saveNewRecord(record)
                }

            }
        }
        
        do {
            try managedContext.save()
        } catch _ {
        }
        
        fetchCloudRecords { (records) -> Void in
            if let records = records {
                for fetchRecord in records {
                    if let diaryID = fetchRecord.objectForKey("id") as? String {
                        if let _ = fetchDiaryByID(diaryID) {
//                            println("No need to do thing")
                        } else {
                            print("Create Diary With CKRecords")
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
    
    do {
        try managedContext.save()
    } catch _ {
    }
}

func fetchDiaryByID(id: String) -> Diary? {
    
    let fetchRequest = NSFetchRequest(entityName:"Diary")
    fetchRequest.predicate = NSPredicate(format: "id = %@", id)
    
    do {
        let fetchedResults =
        try managedContext.executeFetchRequest(fetchRequest) as? [Diary]
        
        if let results = fetchedResults {
            return results.first
        } else {
            return nil
        }
    } catch _ {
        return nil
    }

}

extension DiaryCloud: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {

    }
}