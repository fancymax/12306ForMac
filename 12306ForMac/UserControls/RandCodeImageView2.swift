//
//  RandCodeImageView2.swift
//  SelectImageDemo
//
//  Created by fancymax on 16/3/8.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class RandCodeImageView2:NSImageView {
    struct ImageSection {
        var rowIndex: Int
        var colIndex: Int
        
        func isSameSection(section:ImageSection)->Bool{
            if (section.rowIndex == rowIndex) && (section.colIndex == colIndex){
                return true
            }
            else{
                return false
            }
        }
    }
    
    private var imageSections = [ImageSection]()
    private func convertSectionToRandCode(section:ImageSection)->(Int,Int){
        var randX = 0
        var randY = 0
        if section.rowIndex == 0 {
            randY = 110
        }
        else{
            randY = 40
        }
        
        if section.colIndex == 0{
            randX = 40
        }
        else if section.colIndex == 1{
            randX = 110
        }
        else if section.colIndex == 2{
            randX = 180
        }
        else{
            randX = 255
        }
        return (randX,randY)
    }
    var randCodeStr:String?{
        get{
            if imageSections.count == 0{
                return nil
            }
            var (randX,randY) = convertSectionToRandCode(imageSections[0])
            var str = "\(randX),\(randY)"
            if imageSections.count >= 2{
                for i in 1...imageSections.count - 1 {
                    (randX, randY) = convertSectionToRandCode(imageSections[i])
                    str += ",\(randX),\(randY)"
                }
            }
            return str
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let section = indentifySection(theEvent)
        
        var shouldAdd = true
        if imageSections.count > 0{
            for i in 0...imageSections.count - 1 {
                if imageSections[i].isSameSection(section){
                    imageSections.removeAtIndex(i)
                    shouldAdd = false
                    break
                }
            }
        }
        
        if shouldAdd {
            imageSections.append(section)
        }
        
        needsDisplay = true
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        NSColor.redColor().set()
        
        for section in imageSections
        {
            drawSection(section)
        }
    }
    
    func clearRandCodes()
    {
        imageSections = [ImageSection]()
        needsDisplay = true
    }
    
    //识别点击在哪个区域
    private func indentifySection(theEvent: NSEvent) ->ImageSection{
        var section = ImageSection(rowIndex: 1, colIndex: 1)
        
        let frameOffsetInWindow = convertPoint(self.frame.origin, fromView: nil)
        let mouseX = theEvent.locationInWindow.x
        let mouseY = theEvent.locationInWindow.y
        let pointX = mouseX - (self.frame.origin.x - frameOffsetInWindow.x)
        let pointY = mouseY - (self.frame.origin.y - frameOffsetInWindow.y)
        
        if pointY < 100 {
            section.rowIndex = 0
        }
        else{
            section.rowIndex = 1
        }
        
        if pointX < 85 {
            section.colIndex = 0
        }
        else if pointX < 175 {
            section.colIndex = 1
        }
        else if pointX < 260 {
            section.colIndex = 2
        }
        else if pointX < 345 {
            section.colIndex = 3
        }
        else{
            section.colIndex = 3
        }
        
        Swift.print("pointX = \(pointX) pointY = \(pointY)")
        Swift.print("rowIndex = \(section.rowIndex) colIndex = \(section.colIndex)")
        
        return section
    }
    
    
    //dama to section
    private func damaPoint2Section(X pointX:Double,Y pointY:Double) -> ImageSection{
        var section = ImageSection(rowIndex: 1, colIndex: 1)
        
        if pointY > 110 {
            section.rowIndex = 0 //从下往上
        }
        else{
            section.rowIndex = 1
        }
        
        if pointX < 75 {
            section.colIndex = 0
        }
        else if pointX < 146 {
            section.colIndex = 1
        }
        else if pointX < 220 {
            section.colIndex = 2
        }
        else{
            section.colIndex = 3
        }
        return section
    }
    
    //119,65|24,76
    func drawDamaCodes(damaCodes:String){
        let damaFrameStrs = damaCodes.componentsSeparatedByString("|")
        for damaFrameStr in damaFrameStrs {
            let damaFramePair = damaFrameStr.componentsSeparatedByString(",")
            let pointX = Double(damaFramePair[0])
            let pointY = Double(damaFramePair[1])
            
            imageSections.append(damaPoint2Section(X:pointX!, Y: pointY!))
        }
        needsDisplay = true
    }
    
    
    
    //绘制特定正方形区域
    private func drawSection(section:ImageSection){
        let point = CGPoint(x: 4 + section.colIndex/2 + section.colIndex * 85,
            y: 10 + section.rowIndex + section.rowIndex * 85)
        let size = CGSize(width: 85, height: 85)
        let rect = NSRect(origin: point, size: size)
        let path = NSBezierPath(rect: rect)
        path.lineWidth = 3
        path.stroke()
    }
    
}