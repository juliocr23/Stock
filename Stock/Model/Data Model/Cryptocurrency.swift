//
//  Cryptocurrency.swift
//  Stock
//
//  Created by Julio Rosario on 8/13/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation

class Cryptocurrency: Codable {
    
    //DataFilePath to available cryptocurrencies
    static let dataFilePath = FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first?.appendingPathComponent("Cryptocurrencies")
    
    static let  availableCryptos: [Cryptocurrency] = loadCryptocurrencies()
    
    var name:    String
    var symbol:  String
    
    init(name: String, symbol: String) {
        self.name = name
        self.symbol = symbol
    }
    
    static func parseCSVIntoCrypto(fileName: String)->[Cryptocurrency] {
        
        //Clean file
        var text = fileName.contentsOrBlank()
        text = text.replacingOccurrences(of: "\r", with: "")
        let data =  text.components(separatedBy: "\n")
        
        //Get array of Cryptocurrencies
        var crypBank = [Cryptocurrency]()
        for i in 1...data.count-2 {
            
            let columns = data[i].components(separatedBy: ",")
            
            let crypto = Cryptocurrency(name: columns[1], symbol: columns[0])
            crypBank.append(crypto)
        }
        return crypBank
    }
    
    static func loadCryptocurrencies()->[Cryptocurrency] {
        
        var cryptos = [Cryptocurrency]()
        if let data = try? Data(contentsOf: dataFilePath!) {
          
            let decoder = PropertyListDecoder()
            
            do {
                cryptos = try decoder.decode([Cryptocurrency].self, from: data)
            }catch {
                print("Error loading cryptos \(error)")
            }
        }
        
        cryptos.sort{ $0.name < $1.name }
        return cryptos
    }
}
