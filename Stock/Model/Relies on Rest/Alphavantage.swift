//
//  Alphavantage.swift
//  Stock
//
//  Created by Julio Rosario on 8/24/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//
// "2Y3EEPZRVD37CT31"
import Foundation
struct Alphavantage {
    
    let url:String    = "https://www.alphavantage.co/query"
    var function: Function
    var apikey:String
    var market:String
    var symbol:String
    
    var historicalData: [String:String] {
        get {
            return ["function": function.rawValue,
                    "apikey": apikey,
                    "market": market,
                    "symbol": symbol]
        }
    }
    
    var rate: [String:String] {
        get {
            return ["function": function.rawValue,
                    "from_currency": symbol,
                    "to_currency": market,
                    "apikey": apikey]
        }
    }
}

public enum Function: String {
   case daily   = "DIGITAL_CURRENCY_DAILY"
   case rate     = "CURRENCY_EXCHANGE_RATE"
   case weekly   = "FX_WEEKLY"
   case monthly  = "FX_MONTHLY"
}

