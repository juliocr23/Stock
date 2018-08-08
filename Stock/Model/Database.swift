//
//  Database.swift
//  Stock
//
//  Created by Julio Rosario on 8/3/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class Database {
    
    //Cryptocurrency model
    var cryptocurrency = Cryptocurrency(crypto: .Bitcoin)
   
    //CoinMarket model
    var coinMarket = CoinMarketCap()
    
    //Get database and reference to document
    var db: Firestore!
    
    //Graph model
    var chart = Graph()
    
    var period = 7
    
    var data : [String: [String: Double]]?
    
    var updating = false
    var reading  = false
    
    var docRef: DocumentReference {
        get {
            return db.collection("cryptocurrencies")
                .document(cryptocurrency.name())
        }
    }
    
    init() {
        configureDB()
    }
    
    func configureDB(){
        
        FirebaseApp.configure()
        
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        docRef.addSnapshotListener(includeMetadataChanges: true) { (document, err) in
            
            guard let doc = document else {
                print("Error fetching document: \(err!)")
                return
            }
            
            ///let source = doc.metadata.hasPendingWrites ? "Local" : "Server"
            //print("\(source) data: \(String(describing: doc.data()))")
            
            if !doc.metadata.hasPendingWrites {
                self.updating = false
                print("Hurra")
            }
        }
    }
    
    
    func writeDataToDB(url: String){
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            //Get html document
            let html =  self.coinMarket.getHTML(url: url)
            
            if html != nil {
                
                //Parse data from html
                self.chart.data = self.coinMarket.getHistory(html: html!)
                
                //Put data in DB
                for value in self.chart.data! {
                    self.docRef.setData(value.dictionary , merge: true)
                    
                }
            }
        }
    }
    
    func readDateFromDB(getData: @escaping ([String: [String: Double]]) -> Void) {
        
        
        self.reading = true
        //Get Data from document
        docRef.getDocument { (document, err) in
            
            //Get document if not nil
            if let doc = document {
                
                print("Document Exist")
                self.data = doc.data() as? [String: [String: Double]]
                getData(self.data!)
                self.reading = false
            }
            else {
                print("There was an error Getting document")
                print(err.debugDescription)
            }
        }
    }
    func updateDB(data : [String: [String: Double]]) {
        
        let sortedKeys = sort(data: data)
        let lastEntry = sortedKeys[sortedKeys.count-1]
        let yesterday  =  coinMarket.getYesterday()
        
        if lastEntry != yesterday {
            
            updating = true
            coinMarket.startDate =  coinMarket.yyyyMMdd(str: lastEntry)
            coinMarket.endDate   =  coinMarket.yyyyMMdd(str: yesterday)
            writeDataToDB(url: coinMarket.historicalUrl)
            
        }else{
            print("No need to update: They are equal")
        }
    }
    
    func sort(data : [String:[String: Double]]) ->[String]{
        
        let keys = Array(data.keys)
        var convertedArray: [Date] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        //Convert String dates to Dates objects
        for key in keys {
            let date = dateFormatter.date(from: key)
            if let date = date {
                convertedArray.append(date)
            }
        }
        
        //Sorted the dates in descending order
        let sorted = convertedArray.sorted(by: { $0.compare($1) == .orderedAscending })
        var ready = [String]()
        
        //Convert date to String
        for value in sorted {
            ready.append(dateFormatter.string(from:value))
        }
        
        return ready
    }
}
