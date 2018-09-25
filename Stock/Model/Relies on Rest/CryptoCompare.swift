//
//  CryptoCompare.swift
//  Stock
//
//  Created by Julio Rosario on 9/21/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation

struct CryptoCompare {
    var market: String
    var crypSymbol: String
    var limit: Limit
    
    var priceUrl: String {
        return "https://min-api.cryptocompare.com/data/pricemultifull?"
    }
    
    var hisMinUrl: String {
        return "https://min-api.cryptocompare.com/data/histominute?"
    }
    
    var priceRequest: [String: String] {
        return ["fsyms": crypSymbol,
                "tsyms": market,
                "extraParams": "Stock"]
    }
    
    var histRequest: [String: String] {
        return ["fsym": crypSymbol,
               "tsym": market,
               "limit": limit.rawValue,
               "extraParams": "Stock"]
    }
}

enum Limit: String {
    case oneHour  = "60"      //60 minutes
    case oneDay   = "24"      // 24 hours
    case oneWeek  = "7"       // seven days
    case oneMonth = "30"      //30 days
    case oneYear  = "365"
}
