//
//  RandCodeImageView.swift
//  Train12306
//
//  Created by fancymax on 15/8/12.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class RandCodeImageView:NSImageView {
    
    struct ImageDot {
        var randCodeX: Int
        var randCodeY: Int
        var pointX:CGFloat
        var pointY:CGFloat
    }
    
    fileprivate var imageDots = [ImageDot]()
    
    var randCodeStr:String?{
        get{
            if imageDots.count == 0{
                return nil
            } 
            var str = "\(imageDots[0].randCodeX),\(imageDots[0].randCodeY)"
            if imageDots.count >= 2
            {
                for i in 1...imageDots.count - 1{
                    str = str + ",\(imageDots[i].randCodeX),\(imageDots[i].randCodeY)"
                }
            }
            return str
        }
    }
    
    func clearRandCodes()
    {
        imageDots = [ImageDot]()
        needsDisplay = true
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let frameOffsetInWindow = convert(self.frame.origin, from: nil)
        
        let imageOriginX = self.frame.origin.x - frameOffsetInWindow.x
        let imageOriginY = self.frame.origin.y + self.bounds.height - frameOffsetInWindow.y
        let mouseX = theEvent.locationInWindow.x
        let mouseY = theEvent.locationInWindow.y
        let randCodeX = (mouseX - imageOriginX)/1.2
        let randCodeY = (imageOriginY - mouseY)/1.2 - 30
        
        if ((randCodeX < 0) || (randCodeY < 0)){
            return
        }
        
        let pointX = mouseX - (self.frame.origin.x - frameOffsetInWindow.x)
        let pointY = mouseY - (self.frame.origin.y - frameOffsetInWindow.y)
        
        var isAdd = true
        if imageDots.count != 0
        {
            for i in 0...imageDots.count - 1
            {
                if (abs(pointX - imageDots[i].pointX) < 10) && (abs(pointY - imageDots[i].pointY) < 10)
                {
                    imageDots.remove(at: i)
                    isAdd = false
                    break
                }
            }
        }
        if isAdd
        {
            imageDots.append(ImageDot(randCodeX: Int(randCodeX), randCodeY: Int(randCodeY), pointX: pointX, pointY: pointY))
        }
        
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.green.set()
        
        func drawDot(_ pointX: CGFloat,pointY: CGFloat)
        {
            let dotRect = CGRect(origin: NSPoint(x: pointX, y: pointY), size: CGSize.zero).insetBy(dx:-10, dy:-10)
            NSBezierPath(ovalIn: dotRect).fill()
        }
        
        for point in imageDots
        {
            drawDot(point.pointX,pointY: point.pointY)
        }
    }
    
}
