//
//  Diary.swift
//  Diary
//
//  Created by kevinzhow on 15/2/20.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import Foundation
import CoreData

@objc(Diary)
class Diary: NSManagedObject {

    @NSManaged var content: String
    @NSManaged var created_at: NSDate
    @NSManaged var location: String
    @NSManaged var year: NSNumber
    @NSManaged var month: NSNumber

}
