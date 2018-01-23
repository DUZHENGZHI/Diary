//
//  DiaryAutoLayoutCollectionViewCell.swift
//  Diary
//
//  Created by zhowkevin on 15/10/5.
//  Copyright © 2015年 kevinzhow. All rights reserved.
//

import UIKit
import pop

class DiaryAutoLayoutCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: DiaryLabel!
    
    @IBOutlet weak var popView: DiaryPopView!
    
    var selectCell : (() -> Void)?
    
    var labelText: String = "" {
        didSet {
            self.textLabel.updateText(labelText: labelText)
        }
    }
    
    var textInt: Int = 0
    
    var isYear = false
    
    override func awakeFromNib() {
        
        let lineHeight:CGFloat = 5.0
        
        self.textLabel.config(fontname: defaultFont, labelText: labelText, fontSize: 18.0, lineHeight: lineHeight)
        
        let mDoubleUpRecognizer = UITapGestureRecognizer(target: self, action: #selector(DiaryAutoLayoutCollectionViewCell.click))
        
        mDoubleUpRecognizer.numberOfTapsRequired = 1
        
        popView.isUserInteractionEnabled = true
        
        self.textLabel.isUserInteractionEnabled = false
        
        self.popView.addGestureRecognizer(mDoubleUpRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isYear {
            self.textLabel.config(fontname: "TpldKhangXiDictTrial", labelText: labelText, fontSize: 16.0,lineHeight: 5.0)
        }
    }
    
    @objc func click() {
        if let selectCell = selectCell {
            selectCell()
        }
    }


}
