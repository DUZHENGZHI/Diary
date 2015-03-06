//
//  DiaryVerticalTextView.swift
//  Diary
//
//  Created by kevinzhow on 15/3/6.
//  Copyright (c) 2015年 kevinzhow. All rights reserved.
//

import UIKit
import CoreText

class DiaryVerticalTextView: UIView {
    var titleSizeRate: CGFloat!
    var titleForTextSpace: CGFloat!
    
    var text: NSString = ""
    var titleText: NSString = ""
    
    var fontSize: CGFloat = 16.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var lineSpace: CGFloat = 10.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var letterSpace: CGFloat = 8.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var fontName: NSString = "Avenir-Roman" {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
    override func drawRect(rect: CGRect) {
        
        var attrString = NSMutableAttributedString()
        
        if (self.titleText.length > 0) {
            var fontSize = 27.0 as CGFloat
            var titleFont = CTFontCreateWithName(fontName, fontSize, nil)
            var titleAttrDict = getAttributedStringSourceWithString(self.titleText as String, font: titleFont)
            
            var titleAttrString = NSMutableAttributedString(string: (self.titleText as String), attributes: titleAttrDict)
            
            attrString.appendAttributedString(titleAttrString)
            titleForTextSpace = 0
        }
        
        
        if (self.text.length > 0) {
            var font = CTFontCreateWithName(self.fontName, self.fontSize, nil)
            var textAttrDict = getAttributedStringSourceWithString(self.text as String, font:font)
            var textAttrString  = NSMutableAttributedString(string: (self.text as String), attributes: textAttrDict)
            attrString.appendAttributedString(textAttrString)
        }
        
        
        var framesetter = CTFramesetterCreateWithAttributedString(attrString)
        
        var path = CGPathCreateMutable()
        var pathSize = rect.size
        
        var reversingDiff = 0.0 as CGFloat
        
        CGPathAddRect(path, nil, CGRectMake(-reversingDiff, reversingDiff, pathSize.width, pathSize.height))
        
        var fitRange = CFRangeMake(0, 0)
        
        CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSizeMake(pathSize.width, pathSize.height), &fitRange)
        

        let frameDict: NSDictionary = [
            String(kCTFrameProgressionAttributeName): NSNumber(unsignedInt: CTFrameProgression.RightToLeft.rawValue)
        ]
        
        var frame = CTFramesetterCreateFrame(framesetter, fitRange, path, frameDict)
        
        var context = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context)
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        CGContextTranslateCTM(context, 0, pathSize.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        CTFrameDraw(frame, context)
        
        var factRange = CTFrameGetVisibleStringRange(frame)
        
        CGContextRestoreGState(context)
        
    }
    
    
    func getAttributedStringSourceWithString(stringRef:CFString, font:CTFont) -> [NSObject: AnyObject]
    {


        var glyphInfo = CTGlyphInfoCreateWithCharacterIdentifier(CGFontIndex.min,CTCharacterCollection.CharacterCollectionAdobeCNS1, stringRef as CFString)

        var alignment = CTTextAlignment.TextAlignmentJustified
        var lineBreakMode = CTLineBreakMode.ByWordWrapping
        var lineSpace = self.lineSpace
        var paragraphSpace = titleForTextSpace
        
        let alignmentSet = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.Alignment, valueSize: sizeof(CTTextAlignment), value: &alignment)
        
        let LineBreakModeSet = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.LineBreakMode, valueSize: sizeof(CTLineBreakMode), value: &lineBreakMode)
        
        let ParagraphSpacingSet = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.ParagraphSpacing, valueSize: sizeof(CGFloat), value: &paragraphSpace)
        
        let MinimumLineSpacingSet = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.MinimumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpace)
        
        let MaximumLineSpacingSet = CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.MaximumLineSpacing, valueSize: sizeof(CGFloat), value: &lineSpace)
        
        var paragraphStypeSettings = [alignmentSet, LineBreakModeSet, ParagraphSpacingSet, MinimumLineSpacingSet, MaximumLineSpacingSet]
        
        var paragraphStyle = CTParagraphStyleCreate(paragraphStypeSettings, paragraphStypeSettings.count);
    

        var attrDict: [NSString: AnyObject] = [
            String(kCTFontAttributeName)           : font,
            String(kCTGlyphInfoAttributeName)      : glyphInfo,
            String(kCTParagraphStyleAttributeName) : paragraphStyle,
            String(kCTKernAttributeName)		   : self.letterSpace,
            String(kCTLigatureAttributeName)       : true,
            String(kCTVerticalFormsAttributeName)  : true
        ]
    
    
        return attrDict
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
