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
import Firebase
import FirebaseFirestore
import ChameleonFramework
import SwiftSoup


/* KEYS
 {"3R4VKUEH0HOY3W4Y",
 "2Y3EEPZRVD37CT31",
 "Z8V5MX3CKIN23SDJ",
 "FUFRBDOZCXJLG5Z1",
 "K7GDFKDRDGZ5K3RS",
 "EAOHWAS10TRK3G59"};
 */

class ViewController: UIViewController, SearchDelegate {
    
   // var crypto = CryptocurrencyDetailed(name: "Bitcoin", symbol: "BTC" )
    
    //Alphavantage
    var alphavantage: Alphavantage!
    
    //Graph model
    var chart = Graph()
    
    var db:FirestoreCrypto!
    
    var data: [String: FirestoreData]!
    var sortedKeys:  [String]!
    
    var graphIndex = 0
    var days = 7
    
    let rateApiKey       = "2Y3EEPZRVD37CT31"
    let historicalApiKey = "Z8V5MX3CKIN23SDJ"
    
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var marketCap: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var circulatingSupply: UILabel!
    @IBOutlet weak var maxSupply: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var candleStickGraph: CandleStickChartView!
    @IBOutlet var      timeGraphButtons: [UIButton]!
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var percentChange: UILabel!
    @IBOutlet weak var rankConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    @IBOutlet weak var priceConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = FirestoreCrypto(name:"Bitcoin", symbol: "BTC")
        
        alphavantage = Alphavantage(function: .daily,
                                    apikey: historicalApiKey,
                                    market: "USD",
                                    symbol: db.crypto.name)
        
        abjustConstraints()
        SVProgressHUD.show()
        
        getExchangeRate()
        
        db.read(function: checkUpdate)
    }
    
    func getExchangeRate() {
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if let url = URL(string: "https://coinmarketcap.com/currencies/bitcoin/") {
                do {
                    let html = try String(contentsOf: url)
                
                    //Get marketCap, volume, max supply, Circulating supply and rank
                    let info2 = Utilities.getSubString(str: html, start: 55400, end: 396200)
                    let info1 = Utilities.getSubString(str: html, start: 50000, end: 402300)
                    
                    let expression = "[-+]?[0-9]*\\.?[0-9]+"
                    
                    //Get an array of String of numbers from a regular expression
                    // and extract the crypto info
                    var result = Utilities.matches(for: expression , in: info1)
                    self.db.crypto.price  = Double(result[1])!
                    
                    let negative = Double(result[4])!
                    let positive =  Double(result[8])!
                    
                    //Check whether is a positive or negative change
                    //in the last 24hr
                    if negative < 0 {
                        self.db.crypto.change = negative
                    } else{
                        self.db.crypto.change = positive
                    }
                    
                    result = Utilities.matches(for: expression , in: info2)
                    self.db.crypto.marketCap          = Double(result[0])!
                    self.db.crypto.volume             = Int((Double(result[7])?.rounded())!)
                    self.db.crypto.circulatingSupply  = Int((Double(result[17])?.rounded())!)
                    self.db.crypto.maxSupply          = Int((Double(result[23])?.rounded())!)
                    self.db.crypto.rank               = Int(result[result.count-1])!
                    
                    DispatchQueue.main.async {
                         self.updateUI()
                    }
                }
                catch {
                  print("Couldn't load url")
                }
            }
            else {
              print("The url was bad")
            }
        }
    }
    
    func updateUI(){
        
        var display = Utilities.getDisplayFormat(number: Double(db.crypto.volume))
        volume.text = display
        
        display =  Utilities.getDisplayFormat(number: Double(db.crypto.marketCap))
        marketCap.text = display
        
        if db.crypto.maxSupply == 0 {
            maxSupply.text = "N/A"
        }else {
            display = Utilities.getDisplayFormat(number: Double(db.crypto.maxSupply))
            maxSupply.text = display
        }
        
        display =  Utilities.getDisplayFormat(number: Double(db.crypto.circulatingSupply))
        circulatingSupply.text = display
        
        if db.crypto.change >= 0 {
            percentChange.textColor = UIColor.green
        } else{
            percentChange.textColor = UIColor.red
        }
        
        percentChange.text = "(\(db.crypto.change)%) this hour"
        
        rank.text = "Rank " + String(db.crypto.rank)
        price.text = "$" + String(db.crypto.price) + " USD"
        
        icon.image = UIImage(named: db.crypto.name)
        icon.backgroundColor = UIColor.flatBlue()
    }
    
    //MARK: - Graphs Updates
    /****************************************************************************************/
    func fillGraph(){
        
        chart.data.removeAll()
        var temp = days
        
        //Read all Data from sorted keys
        if temp == -1 || days > sortedKeys.count-1 {
           temp = sortedKeys.count-1
        }
        
        //Fill data for chart
        for i in 0...temp {
            
            let key = sortedKeys[i]
            let value = data[key]!
            chart.data.append(value)
        }
        updateGraph()
    }
    
    func updateGraph(){
        
        candleStickGraph.data = chart.getData()
        candleStickGraph.leftAxis.enabled = false
        candleStickGraph.rightAxis.enabled = false
        candleStickGraph.xAxis.enabled = false
        candleStickGraph.setScaleEnabled(false)
        candleStickGraph.setNeedsDisplay()
        candleStickGraph.dragEnabled = false
        candleStickGraph.legend.drawInside = false
        
        setTitle()
        SVProgressHUD.dismiss()
    }
    
    
    //MARK: - Graph Events
    /**************************************************************************/
    @IBAction func oneWeek(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 0
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()

           candleStickGraph.clear()
            SVProgressHUD.show()
          
            print("one week")
            days = 7
            fillGraph()
        }
    }
    
    @IBAction func threeMonth(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 1
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
           candleStickGraph.clear()
            SVProgressHUD.show()
            
            print("Three months")
            days = 90
            fillGraph()
        }
    }
    
    @IBAction func sixMonth(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 2
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
             candleStickGraph.clear()
            SVProgressHUD.show()
            
            print("six months")
            days = 182
            fillGraph()
        }
    }
    
    @IBAction func nineMonth(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 3
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
             candleStickGraph.clear()
            SVProgressHUD.show()
            
            print("9 months")
            days = 273
            fillGraph()
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
            fillGraph()
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
            fillGraph()
        }
    }
    
    //MARK: Check update
    func checkUpdate(keys: [String], data: [String: FirestoreData]) {
        
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
           Utilities.getJsonRequest(url: alphavantage.url,
                                     parameters: alphavantage.historicalData,
                                     function: updateData)
        } else {
            print("There is  no update filling graph")
            fillGraph()
        }
    }
    
    
    func updateData(json: JSON){
        
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
    }
    
    //MARK: parseAlphavantageJSON
    func parseJsonAlphavantage(json: JSON)->[String: FirestoreData]{
        
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
    }
    
    func setTitle(){
           self.title =  db.crypto.name + " (" + db.crypto.symbol +  ")"
    }
    
    //MARK: - SearchDelegate
    //******************************************************************************************\\
    func selectedCryptocurrency(name:  String, symbol: String) {
        
        //Show progress
        SVProgressHUD.show()
        
        setTitle()
        
        //Clear graph
        candleStickGraph.clear()
        
        //Update alphavantage
        alphavantage.symbol = symbol
        
        //Update Firebase info
        db.crypto.name   = name
        db.crypto.symbol = symbol
        db.read(function: checkUpdate)
    }
    
    
    //MARK - Segues
     /****************************************************************************************/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "goToSearch" {
            
            let destinationVC =  segue.destination as! SearchViewController
            destinationVC.delegate = self
        }
    }
    
  
    func abjustConstraints(){
        
        if  UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            
            rankConstraint.constant = CGFloat(90)
            view.layoutIfNeeded()
            
            print("Doing Constraint")
        } else if  UIDevice.current.screenType == .iPhoneX {
            
            rankConstraint.constant = CGFloat(120)
            constraint.constant = CGFloat(-50)
            priceConstraint.constant = CGFloat(60)
            timeConstraint.constant  = CGFloat(50)
            view.layoutIfNeeded()
        }
    }
  
}

