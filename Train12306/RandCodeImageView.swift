//
//  RandCodeImageView.swift
//  Train12306
//
//  Created by fancymax on 15/8/12.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

struct ImageDot {
    var randCodeX: Int
    var randCodeY: Int
    var pointX:CGFloat
    var pointY:CGFloat
}

class RandomCodeImageView:NSImageView {
    
    private var imageDots = [ImageDot]()
    
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
    
    override func mouseDown(theEvent: NSEvent) {
        let imageOriginX = self.frame.origin.x
        let imageOriginY = self.frame.origin.y + self.bounds.height
        let mouseX = theEvent.locationInWindow.x
        let mouseY = theEvent.locationInWindow.y
        let X = (mouseX - imageOriginX)/1.2 - 5
        let Y = (imageOriginY - mouseY)/1.2 - 15
        println("\(Int(X)),\(Int(Y))")
        
        if Y < 20
        {
            return
        }
        
        let pointX = mouseX - self.frame.origin.x
        let pointY = mouseY - self.frame.origin.y
        var newImageDot = ImageDot(randCodeX: Int(X), randCodeY: Int(Y), pointX: pointX, pointY: pointY)
        var isAdd = true
        if imageDots.count != 0
        {
            for i in 0...imageDots.count - 1
            {
                if (abs(pointX - imageDots[i].pointX) < 10) && (abs(pointY - imageDots[i].pointY) < 10)
                {
                    imageDots.removeAtIndex(i)
                    isAdd = false
                    break
                }
            }
        }
        if isAdd
        {
            imageDots.append(newImageDot)
        }
        
        needsDisplay = true
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        NSColor.greenColor().set()
        
        for point in imageDots
        {
            drawDot(point.pointX,pointY: point.pointY)
        }
    }
    
    func drawDot(pointX: CGFloat,pointY: CGFloat)
    {
        let dotRect = CGRect(origin: NSPoint(x: pointX, y: pointY), size: CGSizeZero).rectByInsetting(dx:-10, dy:-10)
        NSBezierPath(ovalInRect: dotRect).fill()
    }
    
    
    
}
