//
//  TicketQueryService.swift
//  
//
//  Created by fancymax on 15/7/30.
//
//

import Foundation

//TicketQueryService

extension HTTPService {
    //查票网址有可能是变化的
    
    func loadInitPage()
    {
        shareHTTPManager.responseSerializer = AFHTTPResponseSerializer()
        shareHTTPManager.GET(
            "https://kyfw.12306.cn/otn/leftTicket/init",
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                let test1 = NSString(data: (responseObject as! NSData), encoding: NSUTF8StringEncoding)
                let test = String(test1!)
                println(test)
                
//                if let matches = Regex("CLeftTicketUrl\\s*=\\s*['\"\"]([^'\"\"]+)['\"\"];").getMatches(test)
//                {
//                    for match in matches
//                    {
//                        println(match)
//                        self.queryUrl = match
//                    }
//                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )
    }
    
    func queryTicket(fromStation:String,toStation:String,date:String,successHandler handle:(leftTickets:[QueryLeftNewDTO])->())
    {
        var tickets = [QueryLeftNewDTO]()
        var isStudent = "ADULT"
        var queryParam = "?leftTicketDTO.train_date=\(date)&leftTicketDTO.from_station=\(fromStation)&leftTicketDTO.to_station=\(toStation)&purpose_codes=\(isStudent)"
        
        let queryUrl = "leftTicket/query"
        
        let queryLeftTicketUrlLog = "https://kyfw.12306.cn/otn/leftTicket/log" + queryParam
        let queryLeftTicketUrl = "https://kyfw.12306.cn/otn/" + queryUrl + queryParam
        
        println(queryLeftTicketUrlLog)
        println(queryLeftTicketUrl)
        
        shareHTTPManager.responseSerializer = AFJSONResponseSerializer()
        shareHTTPManager.GET(
            queryLeftTicketUrlLog,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )
        
        shareHTTPManager.GET(
            queryLeftTicketUrl,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                
                if(responseObject != nil)
                {
                    let json = JSON(responseObject)
                    let count = json["data"].count
                    for i in 0..<count
                    {
                        var leftTicket = QueryLeftNewDTO(jsonData: json["data"][i]["queryLeftNewDTO"])
                        leftTicket.SecretStr = json["data"][i]["secretStr"].string
                        tickets.append(leftTicket)
                    }
                    
                    handle(leftTickets:tickets)
                }
                else
                {
                    println("nil")
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )
    }
    
}
