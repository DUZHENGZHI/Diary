//
//  CKManager.swift
//  Diary
//
//  Created by kevinzhow on 15/7/7.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import Foundation
import CloudKit

let container = CKContainer(identifier: icloudIdentifier())
let publicDB = container.publicCloudDatabase
let privateDB = container.privateCloudDatabase

func saveNewRecord(diary: Diary) {
    
    var newDiary = CKRecord(recordType: "Diary")
    
    updateRecord(diary, newDiary)
}

func updateRecord(diary: Diary, record: CKRecord) {
    
    record.setObject(diary.content, forKey: "Content")
    
    record.setObject(diary.created_at, forKey: "Created_at")
    
    if let location = diary.location {
        record.setObject(location, forKey: "Location")
    }
    
    if let title = diary.title {
        record.setObject(title, forKey: "Title")
    }
    
    record.setObject(diary.id, forKey: "id")
    
    privateDB.saveRecord(record, completionHandler: { (newDiary, error) -> Void in
        
        println(newDiary)
        
        if let error = error {
            println("error \(error.description)")
        }
        
    })
}

func fetchCloudRecordWithID(recordID: String , complete: (CKRecord?) -> Void) {
    
    var predicate = NSPredicate(format: "id == %@", recordID)
    
    let query = CKQuery(recordType: "Diary",
        predicate: predicate )
    
    privateDB.performQuery(query, inZoneWithID: nil) {
        results, error in
        
        if error != nil {
            println(error.description)
            complete(nil)
        } else {
            println("Have \(results.count) in Cloud")
            if let record = results.first as? CKRecord {
                complete(record)
            } else {
                complete(nil)
            }

        }
    }
}

func fetchCloudRecords(complete: ([CKRecord]?) -> Void) {
    
        var predicate = NSPredicate(format: "TRUEPREDICATE", argumentArray: nil)
    
        let query = CKQuery(recordType: "Diary",
            predicate: predicate )

        privateDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            
            if error != nil {
                println(error.description)
                complete(nil)
            } else {
                println("Have \(results.count) in Cloud")
                if let records = results as? [CKRecord] {
                    complete(records)
                    
//                    for record in records {
//                        privateDB.deleteRecordWithID(record.recordID, completionHandler: { (recordID, error) -> Void in
//                            
//                        })
//                    }

                } else {
                    complete(nil)
                }

            }
        }
}