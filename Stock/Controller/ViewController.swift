//
//  ViewController.swift
//  Stock
//
//  Created by Julio Rosario on 7/13/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import Charts
import SVProgressHUD
import FirebaseFirestore
import ChameleonFramework
import SwiftSoup
import CoreData


/* KEYS
 {"3R4VKUEH0HOY3W4Y",
 "2Y3EEPZRVD37CT31",
 "Z8V5MX3CKIN23SDJ",
 "FUFRBDOZCXJLG5Z1",
 "K7GDFKDRDGZ5K3RS",
 "EAOHWAS10TRK3G59"};
 */


/*
 
 Problem:
 
 OneHour  ->Get data every minutes
 oneDay   ->Get Data every Hour
 oneWeek  ->Get Data daily
 oneMonth ->Get Data daily
 oneYear  ->Get Data daily
 allTime  ->Get Data daily
 
 
 if there is an update for the oneHour {
    Delete OneHour Data.
    Get New OneHour Data.
 }
 
 if there is an update for the oneDay {
    Delete oneDay Data
    Get new oneDay Data
 }
 
 if there is an update for daily {
    Get new daily data
    append daily data to DB
 }
 
 NOTE: Time interval from day through All are the same
 
 TODO: Create Dabase for Crypto
 
 Optimization: Pass the requet and the predicate to the function instead
 
 */

class ViewController: UIViewController, SearchDelegate {
    
    //CryptoCompare
    var crypComp: CryptoCompare!
    var priceData = PriceData()
    var crypto: Crypto!
    var data: [HistoricalData]!
    var dateType: DateType = .mins
    
    //Graph
    var graphModel = Graph()
    var graphIndex = 0
    
    @IBOutlet weak var marketCap: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var candleStickGraph: CandleStickChartView!
    @IBOutlet var      timeGraphButtons: [UIButton]!
    @IBOutlet weak var circulatingSupply: UILabel!
    @IBOutlet weak var highDay: UILabel!
    @IBOutlet weak var lowDay: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var percentChange: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var predicate: NSPredicate {
        get {
         return NSPredicate(format: "(parentCrypto.id MATCHES %@) AND (dateType == %@)",
                                       crypto.id! , dateType.rawValue)
        }
    }
    
    var dbLimit: Int = 0
    var interval: Double = 3600
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Start with Bitcoin as default value
        crypComp = CryptoCompare(market: "USD", crypSymbol: "BTC", limit: "60",url: CryptoCompare.minUrl)
       
        //Load default Crypto
        loadCryptoFromDB()
        
        loadHistoricalDataFromDB(predicate: predicate, checkUpdate: true, delete: true)
        
       /* Utilities.getJsonRequest(url: crypComp.url,
                                 parameters: crypComp.allDataRequest,
                                 function: getHistory) */
    }
    
    //MARK: Database Methods
    func saveData(){
        do {
          try  context.save()
          print("Data Save!")
        }
        catch {
            print("Error saving Context \(error)")
        }
    }
    
    func deleteData(){
        
        print("Deleting Data")
        for value in data {
            context.delete(value)
        }
        saveData()
    }
    
    func loadCryptoFromDB(){
        
        let request: NSFetchRequest<Crypto> = Crypto.fetchRequest()
        let predicate = NSPredicate(format:"symbol ==%@" , crypComp.crypSymbol)
        request.predicate = predicate
        
        do {
            var temp = try context.fetch(request)
            if temp.count >= 0 {
               crypto =  temp[0]
            } else {
                print("Crypto NOT found!\(crypComp.crypSymbol)")
            }
        }catch {
            print("Error Fetching data from context \(error)")
        }
    }
    
    func loadHistoricalDataFromDB(predicate: NSPredicate, limit: Int = 0, checkUpdate: Bool = false, delete: Bool = false){
        
        let request: NSFetchRequest<HistoricalData> = HistoricalData.fetchRequest()
        request.predicate = predicate
       
        //Get last added values using a limit
        if limit > 0 {
            do {
                let allElementsCount =  try context.count(for: request)
                request.fetchLimit = limit
                request.fetchOffset = allElementsCount - limit
                request.returnsObjectsAsFaults = false
            }catch {
                print(error)
            }
        }
        
        //Sort the request
        let sortDescriptr = NSSortDescriptor(key: "time", ascending: true)
        request.sortDescriptors = [sortDescriptr]
        
        do {
            data = try context.fetch(request)
            
            if checkUpdate {
                if delete {
                    checkForUpdate(interval: interval, delete: delete)
                } else {
                     checkForUpdate(interval: interval)
                }
            } else {
                fillGraph()
            }
        }catch {
            print("Error Fetching data from context \(error)")
        }
    }
    
    func getImgFor(crypto: String) -> UIImage?{
        
        let request: NSFetchRequest<Crypto> = Crypto.fetchRequest()
        
        let predicate = NSPredicate(format:"symbol ==%@" , crypComp.crypSymbol)
        request.predicate = predicate
        
        var temp: [Crypto]!
        do {
           temp =   try  context.fetch(request)
        }catch {
            print("Error Fetching data from context \(error)")
        }
        
        let image =  UIImage(data: temp[0].img!)!
        
        return image.resize(width: 50, height: 50)
    }
    
    func checkForUpdate(interval: Double, delete: Bool = false){
        
        let now = Date().timeIntervalSince1970
        let lastUpdate = data[data.count-1].time!.timeIntervalSince1970
        
        if (now - lastUpdate) >= interval {
            
            print("Updating DB")
            if delete {
                deleteData()
            } else {
               let diffInDays = Calendar.current.dateComponents([.day],
                                                               from: Date(timeIntervalSince1970: lastUpdate),
                                                                 to: Date(timeIntervalSince1970: now)).day
                
                crypComp.limit = String(diffInDays!)
                print("Print Different in days \(diffInDays!)")
            }
            
            //Get new Data and update DB
            Utilities.getJsonRequest(url: crypComp.url,
                                     parameters: crypComp.histRequest,
                                     function: getHistory)
        } else {
            print("Filling Graph")
            fillGraph()
        }
    }

    //MARK: JSON Methods
    func getExchangeRate(json: JSON) {

        //Extract data from json
        let data =  json["RAW"][crypComp.crypSymbol][crypComp.market]
        priceData.price       = data["PRICE"].doubleValue
        priceData.supply      = data["SUPPLY"].doubleValue
        priceData.highDay     = data["HIGHDAY"].doubleValue
        priceData.lowDay      = data["LOWDAY"].doubleValue
        priceData.volume24hr  = data["TOTALVOLUME24HTO"].doubleValue
        priceData.marketCap   = data["MKTCAP"].doubleValue
        priceData.change24Hr  = data["CHANGEPCT24HOUR"].doubleValue
        priceData.crypSymbol  = json["DISPLAY"][crypComp.crypSymbol][crypComp.market]["FROMSYMBOL"].stringValue
        
        //Update UI
        updateUI()
    }
    
    func getHistory(json: JSON) {
        
        data =  [HistoricalData]()
        for value in json["Data"] {
            
            let newEntry          =  HistoricalData(context: context)
            newEntry.open         =  value.1["open"].doubleValue
            newEntry.high         =  value.1["high"].doubleValue
            newEntry.low          =  value.1["low"].doubleValue
            newEntry.close        =  value.1["close"].doubleValue
            newEntry.volumeFrom   =  value.1["volumefrom"].doubleValue
            newEntry.volumeTo     =  value.1["volumeto"].doubleValue
            newEntry.time         =  Date(timeIntervalSince1970:  value.1["time"].doubleValue)
            newEntry.parentCrypto =  crypto
            newEntry.dateType     =  dateType.rawValue
            data.append(newEntry)
        }
        
        saveData()
        loadHistoricalDataFromDB(predicate: predicate, limit: dbLimit)
    }
    
    
    //MARK: UI Methods
    func updateUI(){
        
        //Get Image for cryptocurrency
        icon.image =  getImgFor(crypto: crypComp.crypSymbol)
        icon.backgroundColor = UIColor.flatBlue()
        
        //Check if change percent is negative or positive
        if priceData.change24Hr >= 0 {
            percentChange.textColor = UIColor.green
        } else {
            percentChange.textColor = UIColor.red
        }
        
        //Display data on UI
        percentChange.text     = "(\(priceData.change24Hr.rounded(places: 2))%) 24H"
        price.text             = "$" + String(priceData.price)
        lowDay.text            = "$" + String(priceData.lowDay)
        highDay.text           = "$" + String(priceData.highDay)
        volume.text            = "$" + Utilities.getDisplayFormat(number: priceData.volume24hr)
        circulatingSupply.text =  priceData.crypSymbol + Utilities.getDisplayFormat(number: priceData.supply)
        marketCap.text         = "$" + Utilities.getDisplayFormat(number: priceData.marketCap)
    }
    
    
    //MARK: - Graph Methods
    /**************************************************************************/
    
    func fillGraph(){
        
        candleStickGraph.data = graphModel.getData(data: data)
        candleStickGraph.leftAxis.enabled = false
        candleStickGraph.rightAxis.enabled = false
        candleStickGraph.xAxis.enabled = false
        candleStickGraph.setScaleEnabled(false)
        candleStickGraph.setNeedsDisplay()
        candleStickGraph.dragEnabled = false
        candleStickGraph.legend.drawInside = false
        
        SVProgressHUD.dismiss()
    }
    
    @IBAction func oneHour(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            //Change the background color for selected button
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 0
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()

            candleStickGraph.clear()
            SVProgressHUD.show()
            
            //Load one hour data from DB
            dateType       = .mins
            dbLimit        = 0
            crypComp.url   = CryptoCompare.minUrl
            crypComp.limit = "60"
            interval       = 3600
            
            SVProgressHUD.show()
            loadHistoricalDataFromDB(predicate: predicate, checkUpdate: true, delete: true)
        }
    }
    
    @IBAction func oneDay(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 1
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            //Load one hour data from DB
            dateType       = .hourly
            dbLimit        = 0
            crypComp.url   = CryptoCompare.hourUrl
            crypComp.limit = "24"
            interval       = 86400
            
            SVProgressHUD.show()
            loadHistoricalDataFromDB(predicate: predicate, checkUpdate: true, delete: true)
            
        }
    }
    
    @IBAction func oneWeek(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 2
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            //Load one week data from DB
            dateType     = .daily
            dbLimit      = 7
            crypComp.url = CryptoCompare.dailyUrl
            interval     = 86400
            
            SVProgressHUD.show()
            loadHistoricalDataFromDB(predicate: predicate, limit: dbLimit, checkUpdate: true)
        }
    }
    
    @IBAction func oneMonth(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 3
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            //Load one month data from DB
            dateType     = .daily
            dbLimit      = 31
            crypComp.url = CryptoCompare.dailyUrl
            interval     = 86400
            
            SVProgressHUD.show()
            loadHistoricalDataFromDB(predicate: predicate, limit: dbLimit, checkUpdate: true)
        }
    }
    
    @IBAction func oneYear(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 4
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            //Load one year data from DB
            dateType     = .daily
            dbLimit      = 365
            crypComp.url = CryptoCompare.dailyUrl
            interval     = 86400
            
            SVProgressHUD.show()
            loadHistoricalDataFromDB(predicate: predicate, limit: dbLimit, checkUpdate: true)
        }
    }
    
    @IBAction func allTime(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 5
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            //Load one year data from DB
            dateType     = .daily
            crypComp.url = CryptoCompare.dailyUrl
            interval     = 86400
            
            SVProgressHUD.show()
            loadHistoricalDataFromDB(predicate: predicate, checkUpdate: true)
        }
    }
    
    //MARK: - SearchDelegate
    //******************************************************************************************\\
    func selectedCryptocurrency(name:  String, symbol: String) {
        
        //Show progress
        SVProgressHUD.show()
        
        //Clear graph
        candleStickGraph.clear()
    }
    
    
    //MARK - Segues
     /****************************************************************************************/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
      /*  if segue.identifier == "goToSearch" {
            let destinationVC =  segue.destination as! SearchViewController
            destinationVC.delegate = self
        }*/
    }
    
  
    func abjustConstraints(){
        
        if  UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            
         //   rankConstraint.constant = CGFloat(90)
            view.layoutIfNeeded()
            
            print("Doing Constraint")
        } else if  UIDevice.current.screenType == .iPhoneX {
            
            //rankConstraint.constant = CGFloat(120)
           // constraint.constant = CGFloat(-50)
           // priceConstraint.constant = CGFloat(60)
          //  timeConstraint.constant  = CGFloat(50)
            view.layoutIfNeeded()
        }
    }
}

enum DateType: String {
    case mins     = "mins"
    case hourly   = "hourly"
    case daily    = "daily"
}

