//
//  cryptocurrencyBank.swift
//  Stock
//
//  Created by Julio Rosario on 7/15/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation
import UIKit

enum CryptocurrencyBank : String {
    
    case Bitcoin       = "BTC"
    case Ethereum      = "ETH"
    case XRP           = "XPR"
    case BitcoinCash   = "BCH"
    case Litecoin      = "LTC"
    case EOS           = "EOS"
    case Stellar       = "XML"
    case Cardano       = "ADA"
    case IOTA          = "MIOTA"
    case Tether        = "USDT"
    
    var name: [String] {
        get {
            return ["Bitcoin","Ethereum","XRP","Bitcoin Cash","EOS",
                    "Litecoin","Stellar","Cardano","IOTA","Tether"]
        }
    }

    var image: [UIImage?] {
        get {
            return
                [
                   UIImage(named: "bitcoin"),
                   UIImage(named: "ethereum"),
                   UIImage(named: "xrp"),
                   UIImage(named: "bitcoinCash"),
                   UIImage(named: "eos"),
                   UIImage(named: "litecoin"),
                   UIImage(named: "stellar"),
                   UIImage(named: "cardano"),
                   UIImage(named: "iota"),
                   UIImage(named: "tether")
                ]
        }
    }
    
    //var image
    func getSymbol() ->String{
        return self.rawValue
    }
    //Needed for getting crypt from coin market
    func getId() -> String {
        return String(self.hashValue+1)
    }
    
    
    //Get cryptocurrencies by the hashValue
    func get(number: Int) -> CryptocurrencyBank {
        if CryptocurrencyBank.Bitcoin.hashValue == number {
            return CryptocurrencyBank.Bitcoin
        }
        else if CryptocurrencyBank.Ethereum.hashValue == number {
            return CryptocurrencyBank.Ethereum
        }
        else if CryptocurrencyBank.XRP.hashValue == number {
            return CryptocurrencyBank.XRP
        }
        else if CryptocurrencyBank.BitcoinCash.hashValue == number {
            return CryptocurrencyBank.BitcoinCash
        }
        else if CryptocurrencyBank.EOS.hashValue == number {
            return CryptocurrencyBank.EOS
        }
        else if CryptocurrencyBank.Litecoin.hashValue == number {
            return CryptocurrencyBank.Litecoin
        }
        else if CryptocurrencyBank.Stellar.hashValue == number {
            return CryptocurrencyBank.Stellar
        }
        else if CryptocurrencyBank.Cardano.hashValue == number {
            return CryptocurrencyBank.Cardano
        }
        else if CryptocurrencyBank.IOTA.hashValue == number {
            return CryptocurrencyBank.IOTA
        }
        else  {
            return CryptocurrencyBank.Tether
        }
    }
}
