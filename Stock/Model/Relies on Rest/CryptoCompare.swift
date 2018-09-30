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
    var limit: String
    
   var url: String
   static let priceUrl  = "https://min-api.cryptocompare.com/data/pricemultifull?"
   static let minUrl = "https://min-api.cryptocompare.com/data/histominute?"
   static let hourUrl  = "https://min-api.cryptocompare.com/data/histohour?"
   static let dailyUrl = "https://min-api.cryptocompare.com/data/histoday?"
    
    var priceRequest: [String: String] {
        return ["fsyms": crypSymbol,
                "tsyms": market,
                "extraParams": "Stock"]
    }
    
    var histRequest: [String: String] {
        return ["fsym": crypSymbol,
               "tsym": market,
               "limit": limit,
               "extraParams": "Stock"]
    }
    
    var allDataRequest: [String: String] {
        return ["fsym": crypSymbol,
                "tsym": market,
                "allData":"true",
                "e": "CCCAGG",
                "extraParams": "Stock"]
    }
}
