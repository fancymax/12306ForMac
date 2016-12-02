//
//  TrainCodeDetailViewController.swift
//  12306ForMac
//
//  Created by fancymax on 2016/06/12.
//  Copyright © 2016年 fancy. All rights reserved.
//

import Cocoa

class TrainCodeDetailViewController: NSViewController {
    @IBOutlet weak var priceLbl: NSTextField!
    var trainCodeDetails: TrainCodeDetails?
    var ticket:QueryLeftNewDTO? {
        didSet {
            
            let queryByTrainCodeParam = QueryByTrainCodeParam(ticket!)
            if self.trainCodeDetails != nil {
                self.trainCodeDetails!.trainNos!.removeAll()
                self.trainCodeDetailTable.reloadData()
            }
            let successHandler = { (trainDetails:TrainCodeDetails)->()  in
                self.trainCodeDetails = trainDetails
                self.trainCodeDetailTable.reloadData()
            }
            let failureHandler = {(error:NSError)->() in }
            Service.sharedInstance.queryTrainDetailFlowWith(queryByTrainCodeParam, success: successHandler, failure: failureHandler)
            
            let queryTrainPriceParam = QueryTrainPriceParam(ticket!)
            let priceSuccessHandler = { (trainPrice:TrainPrice)->()  in
                self.priceLbl.stringValue = trainPrice.trainPriceStr
               
            }
            Service.sharedInstance.queryTrainPriceFlowWith(queryTrainPriceParam, success: priceSuccessHandler, failure: failureHandler)
        }
    }
    
    @IBOutlet weak var trainCodeDetailTable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup Table Header
        for col in trainCodeDetailTable.tableColumns {
            col.headerCell = TrainCodeDetailHeaderCell(textCell: col.headerCell.stringValue)
            col.headerCell.alignment = .center
        }
    }
}

// MARK: - NSTableViewDataSource 
extension TrainCodeDetailViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        if trainCodeDetails == nil {
            return 0
        }
        return trainCodeDetails!.trainNos.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return trainCodeDetails!.trainNos[row]
    }
}

// MARK: - NSTableViewDelegate
extension TrainCodeDetailViewController:NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}
