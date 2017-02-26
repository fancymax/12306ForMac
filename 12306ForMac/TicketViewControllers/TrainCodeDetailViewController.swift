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
    @IBOutlet weak var trainCodeDetailTable: NSTableView!
    
    private let _trainDetailParam: QueryTrainCodeParam
    private let _trainPriceParam: QueryTrainPriceParam
    var trainCodeDetails: TrainCodeDetails?
    
    init(trainDetailParams:QueryTrainCodeParam,trainPriceParams:QueryTrainPriceParam) {
        _trainDetailParam = trainDetailParams
        _trainPriceParam = trainPriceParams
        super.init(nibName: nil, bundle: nil)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup Table Header
        for col in trainCodeDetailTable.tableColumns {
            col.headerCell = TrainCodeDetailHeaderCell(textCell: col.headerCell.stringValue)
            col.headerCell.alignment = .center
        }
        
        let successHandler = { (trainDetails:TrainCodeDetails)->()  in
            self.trainCodeDetails = trainDetails
            self.trainCodeDetailTable.reloadData()
        }
        let failureHandler = {(error:NSError)->() in }
        Service.sharedInstance.queryTrainDetailFlowWith(_trainDetailParam, success: successHandler, failure: failureHandler)
        
        let priceSuccessHandler = { (trainPrice:TrainPrice)->()  in
            self.priceLbl.stringValue = trainPrice.trainPriceStr
            
        }
        Service.sharedInstance.queryTrainPriceFlowWith(_trainPriceParam, success: priceSuccessHandler, failure: failureHandler)
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
