//
//  CryptoCompare.swift
//  Stock
//
//  Created by Julio Rosario on 9/21/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation

struct CryptoCompare {
    
    let url: String  = "https://min-api.cryptocompare.com/data/"
    var market: String
    var crypSymbol: String
    
    var priceUrl: String {
        return url + "pricemultifull?"
    }
    
    var priceRequest: [String: String] {
        return ["fsyms": crypSymbol,
                "tsyms": market,
                "extraParams": "Stock"]
    }
}
