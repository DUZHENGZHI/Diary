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
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>!
    
    override init() {
        
        super.init()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Diary")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true)]
        
        if let managedContext = DiaryCoreData.sharedInstance.managedContext {
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                managedObjectContext: managedContext, sectionNameKeyPath: nil,
                cacheName: nil)
            
            fetchedResultsController.delegate = self
        }
    }
    
    func startFetch() {
        
        do {
            try fetchedResultsController.performFetch()
            let fetchedResults = fetchedResultsController.fetchedObjects as! [Diary]
            debugPrint("All Diary is \(fetchedResults.count)")
            startSync()
        } catch _ {
            
        }
    }
    
    func startSync() {
        
        debugPrint("New sync")
        
        let allRecords  = fetchedResultsController.fetchedObjects as! [Diary]
        
        fetchCloudRecords { [weak self] records  in
            
            print("Records in CloudKit is \(String(describing: records?.count))")
            print(allRecords.count)
            
            if let records = records {
                
                for fetchRecord in records {
                    
                    // Find Cloud Thing in Local
                    
                    if let diaryID = fetchRecord.object(forKey: "id") as? String,
                        let title = fetchRecord.object(forKey: "Title") as? String{
                        
                        debugPrint("Processing \(diaryID) \(title)")
                        
                        if let _ = fetchDiaryByID(id: diaryID) {
                            debugPrint("No need to do thing")
                        } else {
                            debugPrint("Create Diary With CKRecords")
                            saveDiaryWithCKRecord(record: fetchRecord)
                        }
                    }
                }
                
                for record in allRecords {
                    //Find local in Cloud
                    
                    let filterArray = records.filter { cloud_record -> Bool in

                        if let recordID = cloud_record.object(forKey: "id") as? String, let title = cloud_record.object(forKey: "Title") as? String {
                            
                            if recordID == record.id {
                                
                                debugPrint("OK Processing \(recordID) \(title)")
                                
                                return true
                                
                            } else {
                                
                                return false
                            }
                            
                        } else {
                            return true
                        }
                    }
                    
                    if filterArray.count == 0 {

                        if let _ = record.title {
                            saveNewRecord(diary: record)
                        }
                        
                    } else {
                        debugPrint("No need to upload")
                    }
                    
                }
            }
            
            do {
                try DiaryCoreData.sharedInstance.managedContext?.save()
            } catch _ {
                
            }
            
            self?.removeDupicated()
        }
    }
    
    func removeDupicated() {
        let allRecords  = fetchedResultsController.fetchedObjects as! [Diary]
        
        for record in allRecords {
            
            guard let recordID = record.id else {
                return
            }
            
//            fetchCloudRecordWithTitle(recordID, complete: { (records) -> Void in
//                guard let records = records else {
//                    return
//                }
//                for record in records {
//                    deleteCloudRecord(record)
//                }
//
//            })
            
            var toDelete = [Diary]()
            
            if let fetchedRecords = fetchsDiaryByID(id: recordID) {
                for (index, fetchedRecord) in fetchedRecords.enumerated() {
                    if index != 0 {
                        
                        toDelete.append(fetchedRecord)
                    }
                }
            }
            
            for diary in toDelete {
                DiaryCoreData.sharedInstance.managedContext?.delete(diary)
            }
        }
        
        do {
            try DiaryCoreData.sharedInstance.managedContext?.save()
        } catch _ {
            
        }
        
    }

}


func saveDiaryWithCKRecord(record: CKRecord) {
    if let managedContext = DiaryCoreData.sharedInstance.managedContext {
        
        let entity =  NSEntityDescription.entity(forEntityName: "Diary", in: managedContext)

        if let ID = record.object(forKey: "id") as? String,
            let Content = record.object(forKey: "Content") as? String,
            let Title = record.object(forKey: "Title") as? String,
            let Date = record.object(forKey: "Created_at") as? NSDate {
                
            let newdiary = Diary(entity: entity!,
                                 insertInto:managedContext)
            
            newdiary.id = ID
            
            newdiary.content = Content
            
            let Location = record.object(forKey: "Location") as? String
            newdiary.location = Location
            
            newdiary.title = Title
            
            newdiary.updateTimeWithDate(date: Date)
            
            do {
                try managedContext.save()
                debugPrint("Save diary is \(newdiary)")
            } catch let err {
                debugPrint("Save CKRecord error \(err.localizedDescription)")
            }
        }
    }
}

func fetchDiaryByID(id: String) -> Diary? {
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Diary")
    fetchRequest.predicate = NSPredicate(format: "id = %@", id)
    
    do {
        let fetchedResults =
            try DiaryCoreData.sharedInstance.managedContext?.fetch(fetchRequest) as? [Diary]
        
        if let results = fetchedResults {
            return results.first
        } else {
            return nil
        }
    } catch _ {
        return nil
    }

}

func fetchsDiaryByID(id: String) -> [Diary]? {
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Diary")
    fetchRequest.predicate = NSPredicate(format: "id = %@", id)
    
    do {
        let fetchedResults =
            try DiaryCoreData.sharedInstance.managedContext?.fetch(fetchRequest) as? [Diary]
        
        if let results = fetchedResults {
            return results
        } else {
            return nil
        }
    } catch _ {
        return nil
    }
    
}


func fetchsDiaryByTitle(title: String) -> [Diary]? {
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Diary")
    fetchRequest.predicate = NSPredicate(format: "title = %@", title)
    
    do {
        let fetchedResults =
            try DiaryCoreData.sharedInstance.managedContext?.fetch(fetchRequest) as? [Diary]
        
        if let results = fetchedResults {
            return results
        } else {
            return nil
        }
    } catch _ {
        return nil
    }
    
}

extension DiaryCloud: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    }
}
