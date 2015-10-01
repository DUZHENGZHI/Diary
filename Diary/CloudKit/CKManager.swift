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
    
    let newDiary = CKRecord(recordType: "Diary")
    print("Add New Diary")
    updateRecord(diary, record: newDiary)
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
        
        print("Diary Updated")
        
        if let error = error {
            print("error \(error.description)")
        }
        
    })
}

func fetchCloudRecordWithID(recordID: String , complete: (CKRecord?) -> Void) {
    
    let predicate = NSPredicate(format: "id == %@", recordID)
    
    let query = CKQuery(recordType: "Diary",
        predicate: predicate )
    
    privateDB.performQuery(query, inZoneWithID: nil) {
        results, error in
        if let results = results, record = results.first{
            complete(record)
        } else {
            complete(nil)
        }
    }
}

func fetchCloudRecords(complete: ([CKRecord]?) -> Void) {
    
        let predicate = NSPredicate(format: "TRUEPREDICATE", argumentArray: nil)
    
        let query = CKQuery(recordType: "Diary",
            predicate: predicate )

        privateDB.performQuery(query, inZoneWithID: nil) {
            results, error in
            
            if let results = results{
                complete(results)
            } else {
                complete(nil)
            }
        }
}