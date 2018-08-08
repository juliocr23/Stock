//
//  HistoricalData.swift
//  Stock
//
//  Created by Julio Rosario on 8/2/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct HistoricalData {
    var date: String
    var open: Double
    var high: Double
    var low : Double
    var close: Double
    
   init(date: String, open:Double, high:Double, low: Double, close: Double ) {
        self.date = date
        self.open = open
        self.high = high
        self.low  = low
        self.close = close
    }
    var dictionary: [String:[String:Any]] {
        
    return [ date:    ["open": open,
                       "high": high,
                       "low" : low,
                      "close": close]
           ]
    }
}

