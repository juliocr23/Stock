//
//  Currency.swift
//  Stock
//
//  Created by Julio Rosario on 7/14/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation

class Cryptocurrency {

    var crypto: CryptocurrencyBank
    
    var price: Double?
    
    var volume: Int?
    
    var circulatingSupply: Int?
    
    var change: Double?
    
    var marketCap: Double?
    
    var maxSupply: Int?
    
    var rank: Int?
    
    init(crypto: CryptocurrencyBank) {
       self.crypto = crypto
    }
    
    func getDisplayFormat(number: Double) -> String {
        
        let num = abs(Double(number))
        let sign = (number < 0) ? "-" : ""
        
        switch number {
            
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 2)
            return "$\(sign)\(formatted) B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 2)
            return "$\(sign)\(formatted) M"
            
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 2)
            return "$\(sign)\(formatted) K"
            
        case 0...:
            return "$\(number)"
            
        default:
            return "$\(sign)\(number)"
            
        }
    }
}

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
