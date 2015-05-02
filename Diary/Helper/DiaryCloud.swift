//
//  DiaryCloud.swift
//  Diary
//
//  Created by kevinzhow on 15/5/2.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import Foundation
import CloudKit

let container : CKContainer = CKContainer.defaultContainer()
let publicDB : CKDatabase = container.publicCloudDatabase
let privateDB : CKDatabase = container.privateCloudDatabase