//
//  cryptocurrencyBank.swift
//  Stock
//
//  Created by Julio Rosario on 7/15/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation

enum CryptocurrencyBank :String {
    
    case Bitcoin       = "BTC"
    case Litecoin      = "LTC"
    case Ethereum      = "ETH"
    case XRP           = "XPR"
    case BitcoinCash   = "BCH"
    case EOS           = "EOS"
    case Stellar       = "XML"
    case Cardano       = "ADA"
    case IOTA          = "MIOTA"
    case Tether        = "USDT"
    
    var availableCurrency: [String] {
        get {
            return ["Bitcoin","Ethereum","XRP","BitcoinCash","EOS",
                    "LiteCoin","Stellar","Cardano","IOTA","Tether"]
        }
    }
    
    func getSymbol() ->String{
        return self.rawValue
    }
    
    func getId() -> String {
        return String(self.hashValue+1)
    }
    
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
