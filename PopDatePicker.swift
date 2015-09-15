//
//  PopDatePicker.swift
//  PopDatePicker
//
//  Created by Adam Hartford on 4/22/15.
//  Copyright (c) 2015 Adam Hartford. All rights reserved.
//

import Cocoa

public class PopDatePicker: NSDatePicker {
    
    let controller = PopDatePickerController.new()
    let popover = NSPopover()
    var showingPopover = false
    
    public var preferredPopoverEdge = NSMaxXEdge
    public var shouldShowPopover = { return true }
    
    public override func awakeFromNib() {
        action = "dateAction"
        controller.datePicker.action = "popoverDateAction"
        controller.datePicker.bind(NSValueBinding, toObject: self, withKeyPath: "dateValue", options: nil)
        popover.contentViewController = controller
        popover.behavior = .Semitransient
    }
    
    func popoverDateAction() {
        if let bindingInfo: NSDictionary = infoForBinding(NSValueBinding) {
            if let keyPath = bindingInfo.valueForKey(NSObservedKeyPathKey) as? String {
                bindingInfo.valueForKey(NSObservedObjectKey)?.setValue(dateValue, forKeyPath: keyPath)
            }
        }
    }
    
    func dateAction() {
        controller.datePicker.dateValue = dateValue
    }
    
    public override func mouseDown(theEvent: NSEvent) {
        becomeFirstResponder()
        super.mouseDown(theEvent)
    }
    
    public override func becomeFirstResponder() -> Bool {
        if shouldShowPopover() {
            showingPopover = true
            controller.datePicker.dateValue = dateValue
            popover.showRelativeToRect(bounds, ofView: self, preferredEdge: preferredPopoverEdge)
            showingPopover = false
        }
        return super.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        if showingPopover {
            return false
        }
        popover.close()
        return super.resignFirstResponder()
    }
}

class PopDatePickerController: NSViewController {
    
    let datePicker: NSDatePicker
    
    required init?(coder: NSCoder) {
        datePicker = NSDatePicker()
        super.init(coder: coder)
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        datePicker = NSDatePicker(frame: NSMakeRect(22, 17, 139, 148))
        super.init(nibName: nil, bundle: nil)
        
        let popoverView = NSView(frame: NSMakeRect(0, 0, 180, 180))
        datePicker.datePickerStyle = .ClockAndCalendarDatePickerStyle
        datePicker.drawsBackground = false
        let cell = datePicker.cell() as? NSDatePickerCell
        cell?.bezeled = false
        cell?.sendActionOn(Int(NSEventType.LeftMouseDown.rawValue))
        popoverView.addSubview(datePicker)
        view = popoverView
    }
    
}