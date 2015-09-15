//
//  PreOrderWindowController.swift
//  Train12306
//
//  Created by fancymax on 15/8/14.
//  Copyright (c) 2015年 fancy. All rights reserved.
//

import Cocoa

class PreOrderWindowController: NSWindowController,NSTableViewDataSource,NSTableViewDelegate {

    var trainInfo:QueryLeftNewDTO?
    @IBOutlet weak var orderTicketLabel: NSTextField!
    
    @IBOutlet weak var passengerTable: NSTableView!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var passengerImage: RandomCodeImageView!
    var passengerDTOs:[PassengerDTO]?
    
    let summitService = HTTPService()
    
    @IBAction func FreshImage(sender: NSButton) {
        loadImage()
    }
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let dateStr = ""
        
        orderTicketLabel.stringValue =  dateStr + " " + trainInfo!.TrainCode!
        + " " + trainInfo!.FromStationName! + " " + trainInfo!.start_time! + "-" + trainInfo!.ToStationName! + " " + trainInfo!.arrive_time!
        
        loadImage()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return passengerDTOs!.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if(passengerDTOs!.count - 1 >= row)
        {
            return passengerDTOs![row]
        }
        else
        {
            return nil
        }
    }
    
    
    func loadImage(){
        spinner.startAnimation(nil)
        let handler = {(image:NSImage) -> () in
            self.passengerImage.clearRandCodes()
            self.passengerImage.image = image
            self.spinner.stopAnimation(nil)
        }
        summitService.loadPassengerImage(successHandler: handler)
    }
    
    override var windowNibName: String{
        return "PreOrderWindowController"
    }
    
    @IBAction func okayButtonClicked(button:NSButton){
        summitService.checkRandCodeAnsyn(trainInfo!, passengers: passengerDTOs!, randCodeStr: passengerImage.randCodeStr!)
        dismissWithModalResponse(NSModalResponseOK)
    }
    
    @IBAction func cancelButtonClicked(button:NSButton){
        dismissWithModalResponse(NSModalResponseCancel)
    }
    
    func dismissWithModalResponse(response:NSModalResponse)
    {
        window!.sheetParent!.endSheet(window!,returnCode: response)
    }
}
