//
//  MainViewController.swift
//  Diary
//
//  Created by zhowkevin on 15/10/5.
//  Copyright © 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreData


let DiaryNavTransactionAnimator = DiaryTransactionAnimator()
let HomeYearCollectionViewCellIdentifier = "HomeYearCollectionViewCell"
let DiaryCollectionViewCellIdentifier = "DiaryCollectionViewCell"

class MainViewController: DiaryBaseViewController {
    
    enum InterfaceType: Int {
        case Year
        case Month
        case Day
    }

    @IBOutlet weak var titleLabel: DiaryLabel!
    
    @IBOutlet weak var composeButton: UIButton!
    
    @IBOutlet weak var subLabel: DiaryLabel!
    
    var interfaceType: InterfaceType?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var diarys = [NSManagedObject]()
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>!
    
    var yearsCount: Int = 1
    
    var sectionsCount: Int = 0
    
    var year:Int = 0
    
    var month:Int = 1
    
    @IBOutlet weak var titleLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var subLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var subLabelCenter: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.delegate = DiaryNavTransactionAnimator
        
        if let interfaceType = interfaceType {
            print(interfaceType)
        } else {
            interfaceType = .Year
        }
        
        //Set Up CollectionView Layout
        let yearLayout = DiaryLayout()
        
        self.collectionView.setCollectionViewLayout(yearLayout, animated: false)
        self.collectionView.register(UINib(nibName: "DiaryAutoLayoutCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: DiaryCollectionViewCellIdentifier)
        
        // Add Fetch
        self.prepareFetch()
        self.setupUI()
        
        // Add Gesture
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(popToYear))
        titleLabel.addGestureRecognizer(tapRecognizer)
        let tapSubRecognizer = UITapGestureRecognizer(target: self, action: #selector(popBack))
        subLabel.addGestureRecognizer(tapSubRecognizer)
        
        let mDoubleUpRecognizer = UITapGestureRecognizer(target: self, action: #selector(popBack))
        mDoubleUpRecognizer.numberOfTapsRequired = 2
        self.collectionView.addGestureRecognizer(mDoubleUpRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: NSNotification.Name(rawValue: "DiaryChangeFont"), object: nil)
        resetCollectionView()
        view.layoutIfNeeded()

        // Do any additional setup after loading the view.
    }
    
    func resetCollectionView() {
        
        if portrait {
            self.collectionView.contentInset = calInsets(portrait: true, forSize: CGSize(width: view.frame.size.width, height: view.frame.size.height))
        } else {
            self.collectionView.contentInset = calInsets(portrait: false, forSize:  CGSize(width: view.frame.size.width, height: view.frame.size.height))
        }
        
        if let layout = collectionView.collectionViewLayout as? DiaryLayout {
            layout.collectionViewLeftInsetsForLayout = collectionView.contentInset.left
        }
        
        // Reset CollectionView Offset
        self.collectionView.contentOffset = CGPoint(x: -collectionView.contentInset.left, y: 0)
        
        self.collectionView.reloadData()
        
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Refetch when navigation
        refetch()
        
        self.collectionView.reloadData()
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        self.resetCollectionView()
    }
    
    @objc func reloadCollectionView() {
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }
    
    @objc func popBack() {
        fetchedResultsController.delegate = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func popToYear() {
        fetchedResultsController.delegate = nil
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc func newCompose() {
        
        let composeViewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryComposeViewController") as! DiaryComposeViewController
        
        self.present(composeViewController, animated: true, completion: nil)
        
    }
    
    func setupUI() {
        composeButton.customButtonWith(text: "撰",  fontSize: 14.0,  width: 40.0,  normalImageName: "Oval", highlightedImageName: "Oval_pressed")
        composeButton.addTarget(self, action: #selector(newCompose), for: UIControlEvents.touchUpInside)
        
        var yearTitleStirng = "二零一八"
        
        if year != 0 {
            yearTitleStirng = numberToChinese(number: year)
        }
        
        titleLabel.config(fontname: "TpldKhangXiDictTrial", labelText: "\(yearTitleStirng)年", fontSize: 20.0, lineHeight: 5.0)
        subLabel.config(fontname: defaultFont, labelText: "\(numberToChineseWithUnit(number: month))月", fontSize: 18.0, lineHeight: 5.0)
        subLabel.updateLabelColor(color: DiaryRed)
        
        if let titleLabelSize = titleLabel.labelSize {
            titleLabelHeight.constant = titleLabelSize.height
            print(titleLabelSize.height)
        }
        
        if let subLabelSize = subLabel.labelSize {
            subLabelHeight.constant = subLabelSize.height + 1
            if portrait {
                subLabelCenter.constant = -15
            }else {
                subLabelCenter.constant = 50
            }
        }
        
        if let interfaceType = interfaceType {
            
            switch interfaceType {
            case .Year:
                titleLabel.isHidden = true
                subLabel.isHidden = true
                composeButton.isHidden = true
                
            case .Month:
                subLabel.isHidden = true
            default:
                break
            }

        }

    }

    deinit {
        print("Controller Deinit")
    }

}
