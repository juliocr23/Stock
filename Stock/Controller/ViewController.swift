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

class ViewController: UIViewController, SearchDelegate {
    
    //CryptoCompare
    var crypComp: CryptoCompare!
    var priceData = PriceData()
    var crypto: Crypto!
    
    
    //Graph
    var graphModel = Graph()
    var graphIndex = 0
    var days = 7
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Start with Bitcoin as default value
        crypComp = CryptoCompare(market: "USD", crypSymbol: "BTC", limit: .oneHour)
        loadDataFromDB()
        
        //Get Price,marketCap,volume, high, low and percentChg from CryptoCompare.
        Utilities.getJsonRequest(url: crypComp.hisMinUrl,
                                 parameters: crypComp.histRequest,
                                 function: getOneHourHistory)
    }
    
    func getOneHourHistory(json: JSON) {
    
        var data =  [HistoricalData]()
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
            data.append(newEntry)
        }
        saveData()
    }
    
    //MARK: Database
    func saveData(){
        do {
          try  context.save()
        }
        catch {
            print("Error saving Context \(error)")
        }
    }
    
    func loadDataFromDB(){
        
        let request: NSFetchRequest<Crypto> = Crypto.fetchRequest()
        let predicate = NSPredicate(format:"symbol ==%@" , crypComp.crypSymbol)
        request.predicate = predicate
        do {
            var temp = try context.fetch(request)
            if temp.count > 0 {
               crypto =  temp[0]
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

    //MARK: Update price UI
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
    
    //MARK: - Graphs Updates
    /****************************************************************************************/
    /*func fillGraph(){
        
        graphModel.data.removeAll()
        var temp = days
        
        //Read all Data from sorted keys
        if temp == -1 || days > sortedKeys.count-1 {
           temp = sortedKeys.count-1
        }
        
        //Fill data for chart
        for i in 0...temp {
            
            let key = sortedKeys[i]
            let value = data[key]!
            graphModel.data.append(value)
        }
        updateGraph()
    }*/
    
    func updateGraph(){
        
        candleStickGraph.data = graphModel.getData()
        candleStickGraph.leftAxis.enabled = false
        candleStickGraph.rightAxis.enabled = false
        candleStickGraph.xAxis.enabled = false
        candleStickGraph.setScaleEnabled(false)
        candleStickGraph.setNeedsDisplay()
        candleStickGraph.dragEnabled = false
        candleStickGraph.legend.drawInside = false
        
       // setTitle()
        SVProgressHUD.dismiss()
    }
    
    
    //MARK: - Graph Events
    /**************************************************************************/
    @IBAction func oneHour(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 0
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()

           candleStickGraph.clear()
            SVProgressHUD.show()
          
            print("one week")
            days = 7
           // fillGraph()
        }
    }
    
    @IBAction func oneDay(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 1
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
           candleStickGraph.clear()
            SVProgressHUD.show()
            
            print("Three months")
            days = 90
          //  fillGraph()
        }
    }
    
    @IBAction func oneWeek(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 2
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
             candleStickGraph.clear()
            SVProgressHUD.show()
            
            print("six months")
            days = 182
          //  fillGraph()
        }
    }
    
    @IBAction func oneMonth(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 3
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            print("9 months")
            days = 273
           // fillGraph()
        }
    }
    
    @IBAction func oneYear(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 4
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
           candleStickGraph.clear()
            SVProgressHUD.show()
           
            print("one year")
            days = 365
           // fillGraph()
        }
    }
    
    @IBAction func allTime(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 5
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
            candleStickGraph.clear()
            SVProgressHUD.show()
           
            print("all time")
            days = -1
          //  fillGraph()
        }
    }
    
    //MARK: Check update
    /*func checkUpdate(keys: [String], data: [String: FirestoreData]) {
        
        self.sortedKeys = keys
        self.data = data
        
        var yesterday   = Utilities.getYesterday()
        var lastEntry   = keys[keys.count-1]
        
        //Format yesterday and last entry into yyyyMMdd
        yesterday = Utilities.yyyyMMdd(str: yesterday)
        lastEntry = Utilities.yyyyMMdd(str: lastEntry)
        
        //Get year,month and day from yesterday
        let (yearFromYesterday,
             monthFromYesterday,
             dayFromYesterday)  = Utilities.getYearMonthDayInt(text: yesterday)
        
        //Get year, month and day from last entry
        let (yearFromLastEntry,
             monthFromLastEntry,
             dayFromLastEntry)  = Utilities.getYearMonthDayInt(text: lastEntry)
        
        
        //Check if there is an update
        let needAnUpdate =  yearFromYesterday  > yearFromLastEntry  ||
            monthFromYesterday > monthFromLastEntry ||
            dayFromYesterday   > dayFromLastEntry
        
        if needAnUpdate {
           print("There is an update")
           //Utilities.getJsonRequest(url: alphavantage.url,
                                    // parameters: alphavantage.historicalData,
                                   //  function: updateData)
        } else {
            print("There is  no update filling graph")
            fillGraph()
        }
    } */
    
    
    /*func updateData(json: JSON){
        
        //Get parserJson as a Dictionary and sort keys
        let values = parseJsonAlphavantage(json: json)
        let keys = values.keys.sorted()
        
        //Fill array with new values
        var newData = [String:FirestoreData]()
        for i in sortedKeys.count...keys.count-1 {
          let key = keys[i]
          newData[key] = values[key]
        }
        
        //Write new values to database
        db.write(data: newData)
        
        //Fill graph
        data = values
        sortedKeys = keys
        fillGraph()
    } */
    
    //MARK: parseAlphavantageJSON
    /*func parseJsonAlphavantage(json: JSON)->[String: FirestoreData]{
        
        //Read Historical data from JSON
        var values  = [String: FirestoreData]()
        for (key,subJson) : (String, JSON) in json[json.startIndex].1 {
            
            var temp = FirestoreData()
            temp.open  =  subJson["1b. open (USD)"].doubleValue
            temp.high  =  subJson["2b. high (USD)"].doubleValue
            temp.low   =  subJson["3b. low (USD)"].doubleValue
            temp.close =  subJson["4b. close (USD)"].doubleValue
            
            values[key] = temp
        }
        return values
    } */
    
   /* func setTitle(){
           self.title =  db.crypto.name + " (" + db.crypto.symbol +  ")"
    }*/
    
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

