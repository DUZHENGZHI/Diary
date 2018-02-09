//
//  DiaryCoreData.swift
//  Diary
//
//  Created by zhowkevin on 15/10/30.
//  Copyright © 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

class DiaryCoreDataLegacy: NSObject {
    
    static let sharedInstance = DiaryCoreDataLegacy()
    
    override init() {
        super.init()
        registerForiCloudNotifications()
    }
    
    //Coredata
    
    lazy var managedContext: NSManagedObjectContext? = {
        return self.managedObjectContext
    }()
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "kevinzhow.Diary" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var cloudDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "kevinzhow.Diary" in the application's documents Application Support directory.
        var cloudRoot = icloudIdentifier()
        let url = FileManager.default.url(forUbiquityContainerIdentifier: "\(cloudRoot)")
        debugPrint("\(url)")
        return url! as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Diary", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Diary.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: self.storeOptions)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "Catch.Diary.Error", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var storeOptions: [NSObject : AnyObject] = {
        return [
            NSMigratePersistentStoresAutomaticallyOption:true,
            NSInferMappingModelAutomaticallyOption: true,
            NSPersistentStoreUbiquitousContentNameKey : "CatchDiary",
            NSPersistentStoreUbiquitousPeerTokenOption: "c405d8e8a24s11e3bbec425861s862bs"]
        }() as [NSObject : AnyObject]
    
    func registerForiCloudNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(storesWillChange(notification:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: persistentStoreCoordinator)
        notificationCenter.addObserver(self, selector: #selector(storesDidChange(notification:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: persistentStoreCoordinator)
        notificationCenter.addObserver(self, selector: #selector(persistentStoreDidImportUbiquitousContentChanges(notification:)), name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: persistentStoreCoordinator)
    }
    
    @objc func persistentStoreDidImportUbiquitousContentChanges(notification:NSNotification){
        let context = self.managedObjectContext!
        debugPrint("Perform icloud data change")
        context.performAndWait({
            context.mergeChanges(fromContextDidSave: notification as Notification)
        })
    }
    
    @objc func storesWillChange(notification:NSNotification) {
        debugPrint("Store Will change")
        let context:NSManagedObjectContext! = self.managedObjectContext
        context?.performAndWait({
            if (context.hasChanges) {
                do {
                    try context.save()
                } catch let error as NSError {
                    debugPrint(error.localizedDescription)
                    self.showAlert()
                }
            }
            context.reset()
        })
        
    }
    
    func showAlert() {
        let message = UIAlertView(title: "iCloud 同步错误", message: "是否使用 iCloud 版本备份覆盖本地记录", delegate: self, cancelButtonTitle: "不要", otherButtonTitles: "好的")
        message.show()
    }
    
    
    @objc func storesDidChange(notification:NSNotification){
        debugPrint("Store did change")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CoreDataDidUpdated"), object: nil)
    }
    
    func migrateLocalStoreToiCloudStore() {
        debugPrint("Migrate local to icloud")
        
        if let oldStore = persistentStoreCoordinator?.persistentStores.first {
            var localStoreOptions = self.storeOptions
            localStoreOptions[NSPersistentStoreRemoveUbiquitousMetadataOption as NSString] = true as AnyObject
            
            do {
                let newStore = try persistentStoreCoordinator?.migratePersistentStore(oldStore, to: cloudDirectory as URL, options: localStoreOptions, withType: NSSQLiteStoreType)
                reloadStore(store: newStore)
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
        
        
    }
    
    func migrateiCloudStoreToLocalStore() {
        debugPrint("Migrate icloud to local")
        if let oldStore = persistentStoreCoordinator?.persistentStores.first {
            var localStoreOptions = self.storeOptions
            localStoreOptions[NSPersistentStoreRemoveUbiquitousMetadataOption as NSString ] = true as AnyObject
            
            do {
                let newStore = try persistentStoreCoordinator?.migratePersistentStore(oldStore, to:  self.applicationDocumentsDirectory.appendingPathComponent("Diary.sqlite")!, options: localStoreOptions, withType: NSSQLiteStoreType)
                reloadStore(store: newStore)
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
        
    }
    
    
    func reloadStore(store: NSPersistentStore?) {
        
        if let store = store {
            do {
                let targetURL = self.applicationDocumentsDirectory.appendingPathComponent("Diary.sqlite")
                try persistentStoreCoordinator?.remove(store)
                try persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: targetURL, options: self.storeOptions)
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
            
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CoreDataDidUpdated"), object: nil)
    }
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
}

extension DiaryCoreDataLegacy: UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            self.migrateLocalStoreToiCloudStore()
        case 1:
            self.migrateiCloudStoreToLocalStore()
        default:
            debugPrint("Do nothing")
        }
    }
}
