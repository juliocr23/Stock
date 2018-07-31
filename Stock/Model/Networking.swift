//
//  Networking.swift
//  Stock
//
//  Created by Julio Rosario on 7/22/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Networking {
    
    var json: JSON?
    
    //MARK: - Networking
    /**************************************************************************/
    
    func getCurrencyValue(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            
            if response.result.isSuccess {
                
              self.json = JSON(response.result.value!)
              print("Getting json was successful!")
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
}
