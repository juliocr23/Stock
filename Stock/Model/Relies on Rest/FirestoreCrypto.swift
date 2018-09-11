//
//  FirestoreCrypto.swift
//  Stock
//
//  Created by Julio Rosario on 9/8/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
import SwiftyJSON


class FirestoreCrypto {
    
    let folder = "cryptocurrencies";
    var firebaseDB: Firestore!
    var crypto: CryptocurrencyDetailed
    
    var documentRef: DocumentReference {
        get {
            return firebaseDB.collection(folder).document(crypto.name)
        }
    }
    
    init(name: String,symbol: String) {
       
        crypto = CryptocurrencyDetailed(name: name, symbol: symbol)
        configureDB()
    }
    
    func configureDB(){
        
        FirebaseApp.configure()
       
        firebaseDB = Firestore.firestore()
        
        let settings = firebaseDB.settings
        settings.areTimestampsInSnapshotsEnabled = true
        
        firebaseDB.settings = settings
        
        documentRef.addSnapshotListener(includeMetadataChanges: true) { (document, err) in
            guard let doc = document else {
                print("Error fetching document: \(err!)")
                return
            }
            
            if !doc.metadata.hasPendingWrites {
                print("Hurra")
            }
        }
    }
    
    func write(data: [String:FirestoreData]) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            //Put data in DB
            for value in data {
                self.documentRef.setData([value.key:
                                         ["open": value.value.open,
                                          "high": value.value.high,
                                          "low":  value.value.low,
                                          "close": value.value.close]],
                                           merge: true)
            }
            
            //Check if data has been upload
            self.documentRef.addSnapshotListener(includeMetadataChanges: true, listener: { (document, error) in
                
                if let doc = document {
                    if !doc.metadata.hasPendingWrites {
                        print("Data has been written to Server")
                    }
                }
            })
        }
    }
    
    func read(function: @escaping ([String],[String:FirestoreData]) -> Void ) {
        
        documentRef.getDocument { (document, err) in
            
            if let doc = document, doc.exists {
                
                //Cast data to dictionary and sort keys
                let dict  =  doc.data() as! [String: [String: Double]]
                let sortedKeys = Utilities.sort(data: dict)
                
                //Cast dictionary to a FirestoreData array
                var data = [String: FirestoreData]()
                for i in 0...sortedKeys.count-1 {
                    
                    let key = sortedKeys[i]
                    var temp = FirestoreData()
                    
                    temp.open  =  dict[key]!["open"]!
                    temp.high  =  dict[key]!["high"]!
                    temp.low   =  dict[key]!["low"]!
                    temp.close =  dict[key]!["close"]!
            
                    data[key] = temp
                } 
                //Return function
                function(sortedKeys,data)
            }
            else {
                print("There was an error Getting document")
                print(err.debugDescription)
            }
        }
    }
    
    /*func updateData(){
       Utilities.getJsonRequest(url: alphavantage.url,
                       parameters: alphavantage.dict,
                       function: update)
    }*/
    
    /*private func update(json: JSON) {
    
        //Read Historical data from JSON
        var values  = [String: [String: Double]]()
        for (key,subJson) : (String, JSON) in json[json.startIndex].1 {
            
            let oneDayValue = ["open":  subJson["1b. open (USD)"].doubleValue,
                               "high":  subJson["2b. high (USD)"].doubleValue,
                               "low":   subJson["3b. low (USD)"].doubleValue,
                               "close": subJson["4b. close (USD)"].doubleValue ]
            
            values[key] = oneDayValue
        }
        
        print("Update: \(values)")
        //   writeDataToFirebase(data: values)
        
        //Update FirebaseDB
        let keys   = Utilities.sort(data: values)
        var updateValues   =  [String: [String: Double]]()
        
        for i in sortedKeys.count...keys.count-1 {
            updateValues[keys[i]] = values[keys[i]]
        }
        
        print("Update: \(updateValues)")
        // writeDataToFirebase(data: updateValues)
        
        //Fill graph
        data = values
        sortedKeys = keys
        fillGraph()
    }*/
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
