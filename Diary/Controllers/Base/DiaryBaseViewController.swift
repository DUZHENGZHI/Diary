//
//  DiaryBaseViewController.swift
//  Diary
//
//  Created by kevinzhow on 15/4/26.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData

class DiaryBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return true;
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == UIEventSubtype.motionShake {
            debugPrint("Device Shaked")
            showAlert()
        }
    }
    
    func showAlert() {
        
        let message = UIAlertView(title: "特别事项", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "还原数据")
        message.show()
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension DiaryBaseViewController: UIAlertViewDelegate {
    
    func fetchLagecyRecords() {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Diary")
            
            let oldFetchedRecords = try DiaryCoreDataLegacy.sharedInstance.managedContext?.fetch(fetchRequest) as! [Diary]
            
            NSLog("Lagecy Fetched \(oldFetchedRecords.count)")
            
            let restoreViewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryRestoreTableViewController") as! DiaryRestoreTableViewController
            restoreViewController.diarys = oldFetchedRecords
            let nav = UINavigationController(rootViewController: restoreViewController)
            self.present(nav, animated: true, completion: nil)
        } catch {
            debugPrint("Lagecy Fetched")
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            debugPrint("Cancle")
        case 1:
            debugPrint("Restore")
            fetchLagecyRecords()
        default:
            debugPrint("Do nothing")
        }
    }
}
