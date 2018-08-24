//
//  Cryptocurrency.swift
//  Stock
//
//  Created by Julio Rosario on 8/13/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation

class Cryptocurrency {
    
    var name:    String = ""
    var symbol:  String = ""
    
    var volume:            Int = 0
    var circulatingSupply: Int = 0
    var maxSupply:         Int = 0
    var rank:              Int = 0
    
    var price:     Double = 0
    var change:    Double = 0
    var marketCap: Double = 0
    
    init(name: String) {
      self.name = name
    }
   
}
