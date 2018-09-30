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



/*
 
 
 */

class ViewController: UIViewController, SearchDelegate {
    
    //CryptoCompare
    var crypComp: CryptoCompare!
    var priceData: Price!
    var crypto: Crypto!
    var historicalData: [HistoricalData]!
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
        
        //Add Gesture for swipe down
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeDown))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        SVProgressHUD.show()
        
        //Start with Bitcoin as default value
        crypComp = CryptoCompare(market: "USD", crypSymbol: "BTC", limit: "60",url: CryptoCompare.minUrl)
       
        //Load default Crypto
        loadCryptoFromDB()
        
        //Load price Data
        loadPriceData()
        
        //Load Historical Data
        loadHistoricalDataFromDB(predicate: predicate, checkUpdate: true, delete: true)
        
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
    
    //MARK: Price Methods
    func loadPriceData(){
        let request: NSFetchRequest<Price> = Price.fetchRequest()
        let predicate = NSPredicate(format: "(parentCrypto.id MATCHES %@)",crypto.id!)
        request.predicate = predicate
        
        do {
            var temp = try context.fetch(request)
            if temp.count >= 0 {
               priceData = temp[0]
                
                 //Check for 5 mins interval
                checkPriceUpdate()
            } else {
                print("Price NOT found!\(crypComp.crypSymbol)")
            }
        }catch {
            print("Error Fetching data from context \(error)")
        }
    }
    
    func checkPriceUpdate(){
        
       let last =  priceData.lastUpdate?.timeIntervalSince1970
       let now  =  Date().timeIntervalSince1970
        
        if (now - last!) >= 300 { //There is an update
            
            print("Updating price")
            
            //Delete Data
            context.delete(priceData)
            saveData()
            
            //Get new Data
            Utilities.getJsonRequest(url: CryptoCompare.priceUrl,
                                     parameters:crypComp.priceRequest,
                                     function: getExchangeRate)
        } else {
            updateUIForPriceData()
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
    
    func getExchangeRate(json: JSON) {
        
        //Extract data from json
        let data  =  json["RAW"][crypComp.crypSymbol][crypComp.market]
        priceData = Price(context: context)
        
        priceData.price        = data["PRICE"].doubleValue
        priceData.supply       = data["SUPPLY"].doubleValue
        priceData.highDay      = data["HIGHDAY"].doubleValue
        priceData.lowDay       = data["LOWDAY"].doubleValue
        priceData.volume24H    = data["TOTALVOLUME24HTO"].doubleValue
        priceData.marketCap    = data["MKTCAP"].doubleValue
        priceData.change24H    = data["CHANGEPCT24HOUR"].doubleValue
        priceData.symbol       = json["DISPLAY"][crypComp.crypSymbol][crypComp.market]["FROMSYMBOL"].stringValue
        priceData.lastUpdate   = Date()
        priceData.parentCrypto = crypto
        
        saveData()
        updateUIForPriceData()
    }
    
    
    func updateUIForPriceData(){
        
        //Get Image for cryptocurrency
        icon.image =  getImgFor(crypto: crypComp.crypSymbol)
        icon.backgroundColor = UIColor.flatBlue()
        
        //Check if change percent is negative or positive
        if priceData.change24H >= 0 {
            percentChange.textColor = UIColor.green
        } else {
            percentChange.textColor = UIColor.red
        }
        
        //Display data on UI
        percentChange.text     = "(\(priceData.change24H.rounded(places: 2))%) 24H"
        price.text             = "$" + String(priceData.price)
        lowDay.text            = "$" + String(priceData.lowDay)
        highDay.text           = "$" + String(priceData.highDay)
        volume.text            = "$" + Utilities.getDisplayFormat(number: priceData.volume24H)
        circulatingSupply.text =  priceData.symbol! + Utilities.getDisplayFormat(number: priceData.supply)
        marketCap.text         = "$" + Utilities.getDisplayFormat(number: priceData.marketCap)
    }
    
    
    //MARK: Historical Data Methods
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
            historicalData = try context.fetch(request)
            
            print("Size of Data:\(historicalData.count) ")
            
            if checkUpdate {
                if delete {
                    checkHistoricalDataUpdate(interval: interval, delete: delete)
                } else {
                     checkHistoricalDataUpdate(interval: interval)
                }
            } else {
                fillGraph()
            }
        }catch {
            print("Error Fetching data from context \(error)")
        }
    }
    
    func checkHistoricalDataUpdate(interval: Double, delete: Bool = false){
        
        //Get the time interval for now and the last from DB
        let now = Date().timeIntervalSince1970
        let lastUpdate = historicalData[historicalData.count-1].time!.timeIntervalSince1970
        
        //Interval specify the time requiered for update.
        //If delta is greater than or equal to interval
        //there is an update.
        if (now - lastUpdate) >= interval {
            
            //Check if it has to delete data
            if delete {
                deleteHistoricalData()
            }
            else { //Otherwise check the differece in days and use that number
                   //To request the missing data.
                
               let diffInDays = Calendar.current.dateComponents([.day],
                                                               from: Date(timeIntervalSince1970: lastUpdate),
                                                                 to: Date(timeIntervalSince1970: now)).day
                crypComp.limit = String(diffInDays!)
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
    
    func getHistory(json: JSON) {
        
        historicalData =  [HistoricalData]()
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
            historicalData.append(newEntry)
        }
        saveData()
        loadHistoricalDataFromDB(predicate: predicate, limit: dbLimit)
    }
    
    func fillGraph(){
        
        candleStickGraph.data = graphModel.getData(data: historicalData)
        candleStickGraph.leftAxis.enabled = false
        candleStickGraph.rightAxis.enabled = false
        candleStickGraph.xAxis.enabled = false
        candleStickGraph.setScaleEnabled(false)
        candleStickGraph.setNeedsDisplay()
        candleStickGraph.dragEnabled = false
        candleStickGraph.legend.drawInside = false
        
        SVProgressHUD.dismiss()
    }
    
    func deleteHistoricalData(){
        
        print("Deleting Data")
        for value in historicalData {
            context.delete(value)
        }
        saveData()
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
    
    @objc func respondToSwipeDown(){
        
        SVProgressHUD.show()
        checkPriceUpdate()
        
        //Check Graph updates
        if graphIndex == 0 {
            checkHistoricalDataUpdate(interval: 3600, delete: true)
        } else if graphIndex == 1 {
              checkHistoricalDataUpdate(interval: 86400, delete: true)
        } else {
             checkHistoricalDataUpdate(interval: 86400)
        }
    }
}

enum DateType: String {
    case mins     = "mins"
    case hourly   = "hourly"
    case daily    = "daily"
}

