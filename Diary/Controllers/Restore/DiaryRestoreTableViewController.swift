//
//  DiaryRestoreTableViewController.swift
//  Diary
//
//  Created by 周楷雯 on 2018/2/9.
//  Copyright © 2018年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

class DiaryRestoreTableViewController: UITableViewController {

    @IBAction func backbuttonClicled(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var diarys = [Diary]()
    var currentDiary: Diary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return diarys.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestoreDiaryCell", for: indexPath)

        let diary = diarys[indexPath.row]
        
        cell.textLabel?.text = "\(diary.year) 年 \(diary.month) 月 \(diary.title ?? "")"
        cell.detailTextLabel?.text = diary.content
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint("User selected Diary")
        
        let diary = diarys[indexPath.row]
        currentDiary = diary
        let message = UIAlertView(title: "\(diary.title ?? "")", message: "\(diary.content)", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "还原")
        message.show()

        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}


extension DiaryRestoreTableViewController: UIAlertViewDelegate {
    
    func saveRecord()  {
        if let diary = currentDiary, let managedContext = DiaryCoreData.sharedInstance.managedContext {
            let entity =  NSEntityDescription.entity(forEntityName: "Diary", in: managedContext)
            
            let newdiary = Diary(entity: entity!,
                                 insertInto:managedContext)
            
            newdiary.id = diary.id
            
            newdiary.content = diary.content
            
            if let address  = diary.location {
                newdiary.location = address
            }
            
            newdiary.title = diary.title
            newdiary.created_at = diary.created_at
            
            saveNewRecord(diary: newdiary)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                debugPrint("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            debugPrint("Cancle")
        case 1:
            saveRecord()
        default:
            debugPrint("Do nothing")
        }
    }
}
