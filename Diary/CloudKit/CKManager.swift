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
    debugPrint("Add New Diary To iCloud")
    updateRecord(diary: diary, record: newDiary)
}

func updateRecord(diary: Diary, record: CKRecord) {
    
    record.setObject(diary.content as CKRecordValue, forKey: "Content")
    
    record.setObject(diary.created_at, forKey: "Created_at")
    
    if let location = diary.location {
        record.setObject(location as CKRecordValue, forKey: "Location")
    }
    
    if let title = diary.title {
        record.setObject(title as CKRecordValue, forKey: "Title")
    }
    
    record.setObject(diary.id as CKRecordValue?, forKey: "id")
    
    privateDB.save(record, completionHandler: { (newDiary, error) -> Void in
        
        debugPrint("Diary Updated")
        
        if let error = error {
            debugPrint("error \(error.localizedDescription)")
        }
        
    })
}

func fetchCloudRecordWithID(recordID: String , complete: @escaping (CKRecord?) -> Void) {
    
    let predicate = NSPredicate(format: "id == %@", recordID)
    
    let query = CKQuery(recordType: "Diary",
        predicate: predicate )
    
    privateDB.perform(query, inZoneWith: nil) {
        results, error in
        if let results = results, let record = results.first{
            complete(record)
        } else {
            complete(nil)
        }
    }
}

func deleteCloudRecord(record: CKRecord) {
    privateDB.delete(withRecordID: record.recordID) { (recordID, error) -> Void in
        print("Delete \(String(describing: recordID?.recordName)) \(String(describing: error?.localizedDescription))")
    }
}

func fetchCloudRecordWithTitle(title: String , complete: @escaping ([CKRecord]?) -> Void) {
    
    let predicate = NSPredicate(format: "Title == %@", title)
    
    let query = CKQuery(recordType: "Diary",
        predicate: predicate )
    
    privateDB.perform(query, inZoneWith: nil) {
        results, error in
        if let results = results {
            complete(results)
        } else {
            complete(nil)
        }
    }
}

func fetchCloudRecords(complete: @escaping ([CKRecord]?) -> Void) {

    let predicate = NSPredicate(value: true)

    let query = CKQuery(recordType: "Diary",
        predicate: predicate )
    
    let queryOpration = CKQueryOperation(query: query)
    
    queryOpration.qualityOfService = QualityOfService.userInteractive
    
    var results = [CKRecord]()

    queryOpration.recordFetchedBlock = { (record: CKRecord) in
        results.append(record)
    }
    

    queryOpration.queryCompletionBlock = { cursor, error in
        if let cursor = cursor {
            queryRecordsWithCursor(cursor: cursor, newRecord: { (record) in
                if let record = record {
                    results.append(record)
                }
            }, complete: {
                complete(results)
            })
        } else {
            complete(results)
        }
    }
    
    privateDB.add(queryOpration)

}

func queryRecordsWithCursor(cursor: CKQueryCursor?, newRecord: @escaping (CKRecord?) -> Void , complete: @escaping () -> Void) {
    if let cursor = cursor {
        let queryMoreOpration = CKQueryOperation(cursor: cursor)
        queryMoreOpration.recordFetchedBlock = { (record: CKRecord) in
            newRecord(record)
        }
        queryMoreOpration.queryCompletionBlock = {cursor, error in
            if let cursor = cursor {
                queryRecordsWithCursor(cursor: cursor, newRecord: { (record) in
                    if let record = record {
                        newRecord(record)
                    }
                }, complete: {
                    complete()
                })
            } else {
                complete()
            }
        }
        privateDB.add(queryMoreOpration)
    } else {
        complete()
    }
}
