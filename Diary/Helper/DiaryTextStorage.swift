//
//  DiaryTextStorage.swift
//  Diary
//
//  Created by kevinzhow on 15/3/5.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit

class DiaryTextStorage: NSTextStorage {
   var backingStore: NSMutableAttributedString = NSMutableAttributedString()
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributesAtIndex(index: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
        return backingStore.attributesAtIndex(index, effectiveRange: range)
    }
    
    override func replaceCharactersInRange(range: NSRange, withString str: String) {
//        println("replaceCharactersInRange:\(range) withString:\(str)")
        
        beginEditing()
        backingStore.replaceCharactersInRange(range, withString:str)
        edited(.EditedCharacters | .EditedAttributes, range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }
    
    override func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
//        println("setAttributes:\(attrs) range:\(range)")
        
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    override func processEditing() {
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        var textAttributes: [NSObject : AnyObject]! = [NSFontAttributeName: DiaryFont, NSVerticalGlyphFormAttributeName: 1, NSParagraphStyleAttributeName: paragraphStyle]
        
        
        self.addAttributes(textAttributes, range: self.editedRange)
        super.processEditing()
    }
    

}
