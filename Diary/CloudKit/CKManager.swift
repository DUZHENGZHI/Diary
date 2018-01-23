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
    
    queryOpration.resultsLimit = 20
    
    queryOpration.qualityOfService = QualityOfService.userInteractive
    
    var results = [CKRecord]()
    
    let recordFetchedBlock = { (record: CKRecord) in
        results.append(record)
    }
    
    var queryCompleteBlockSelf = { (cursor: CKQueryCursor?, error: NSError?) in }
    
    let queryCompleteBlock = { (cursor: CKQueryCursor?, error: NSError?) in
        if let cursor = cursor {
            let queryMoreOpration = CKQueryOperation(cursor: cursor)
            queryMoreOpration.queryCompletionBlock = queryCompleteBlockSelf as? (CKQueryCursor?, Error?) -> Void
            queryMoreOpration.recordFetchedBlock = recordFetchedBlock
            privateDB.add(queryMoreOpration)
        } else {
            complete(results)
        }
    }
    
    queryCompleteBlockSelf = queryCompleteBlock

    queryOpration.recordFetchedBlock = recordFetchedBlock
    
    queryOpration.queryCompletionBlock = queryCompleteBlockSelf as? (CKQueryCursor?, Error?) -> Void
    
    privateDB.add(queryOpration)

}
