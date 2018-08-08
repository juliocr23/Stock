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


class ViewController: UIViewController, SearchDelegate{
    
    var DB = Database()
    var index = 0
    
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var marketCap: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var circulatingSupply: UILabel!
    @IBOutlet weak var maxSupply: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var candleStickGraph: CandleStickChartView!
    @IBOutlet var timeGraphButtons: [UIButton]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        SVProgressHUD.show()
        
        getCurrencyValue(url: getTickerURL(),
                         parameters: DB.coinMarket.priceParamerer,
                         updateData: updateCurrencyData)
        
        candleStickGraph.setNeedsDisplay()
        
        //Update DB data if there is an update
        DB.readDateFromDB(getData: fillGraph)
        
    }
    
    func readL(data: [String: [String: Double]]){
        print("Display")
        print(DB.sort(data: data))
    }
    
    
    //MARK: - Get JSON from CoinMarket
    /**************************************************************************/
    
    func getCurrencyValue(url: String, parameters: [String: String], updateData: @escaping (JSON) -> Void) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
          
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                updateData(json)
            }
            else {
                 print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    //Mark: - Update View
    /**************************************************************************/
    func updateCurrencyData(json: JSON){
        
        DB.cryptocurrency.price              = json["data"]["quotes"]["USD"]["price"].doubleValue.rounded(places: 2)
        DB.cryptocurrency.volume             = json["data"]["quotes"]["USD"]["volume_24h"].intValue
        DB.cryptocurrency.marketCap          = json["data"]["quotes"]["USD"]["market_cap"].doubleValue
        DB.cryptocurrency.change             = json["data"]["quotes"]["USD"]["percent_change_24h"].doubleValue
        DB.cryptocurrency.circulatingSupply  = json["data"]["circulating_supply"].intValue
        DB.cryptocurrency.maxSupply          = json["data"]["max_supply"].intValue
        DB.cryptocurrency.rank               = json["data"]["rank"].intValue
        
        updateUI()
    }
    
    func updateUI(){
        
        var display = DB.cryptocurrency.getDisplayFormat(number: Double(DB.cryptocurrency.volume!))
        volume.text = display
        
        display = DB.cryptocurrency.getDisplayFormat(number: Double(DB.cryptocurrency.marketCap!))
        marketCap.text = display
        
        display =  DB.cryptocurrency.getDisplayFormat(number: Double(DB.cryptocurrency.maxSupply!))
        maxSupply.text = display
        
        display = DB.cryptocurrency.getDisplayFormat(number: Double(DB.cryptocurrency.circulatingSupply!))
        circulatingSupply.text = display
        
        rank.text = "Rank " + String(DB.cryptocurrency.rank!)
        price.text = "$" + String(DB.cryptocurrency.price!) + " USD"
        
    }
    
    func fillGraph(data: [String: [String: Double]]){
        
        let sortedKeys = DB.sort(data: data)
        DB.chart.data = [HistoricalData]()
        
        //Read all Data from sorted keys
        if DB.period == -1{
            DB.period = sortedKeys.count
        }
        
        for i in 0...DB.period-1 where sortedKeys.count >= DB.period {
            
            let key = sortedKeys[i]
            let temp = data[key]
            
            let historicalData = HistoricalData(date: key,
                                                open: temp!["open"]!,
                                                high: temp!["high"]!,
                                                low:  temp!["low"]!,
                                                close: temp!["close"]!)
            DB.chart.data?.append(historicalData)
        }
        
        updateGraph()
    }
    
    func updateGraph(){
        candleStickGraph.data = DB.chart.getData()
        candleStickGraph.leftAxis.enabled = false
        candleStickGraph.rightAxis.enabled = false
        candleStickGraph.xAxis.enabled = false
        
        setTitle()
        SVProgressHUD.dismiss()
    }
    
    
    //MARK: - Graph Events
    /**************************************************************************/
    @IBAction func oneWeek(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            
            timeGraphButtons[index].backgroundColor = UIColor.flatBlue()
            index = 0
            timeGraphButtons[index].backgroundColor = UIColor.flatPowderBlueColorDark()

            
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            DB.period = 7
            
            if DB.data == nil {
                DB.readDateFromDB(getData: fillGraph)
            }else{
                fillGraph(data: DB.data!)
            }
        }
    }
    
    @IBAction func threeMonth(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            timeGraphButtons[index].backgroundColor = UIColor.flatBlue()
            index = 1
            
            timeGraphButtons[index].backgroundColor = UIColor.flatPowderBlueColorDark()
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            DB.period = 90
            
            if DB.data == nil {
                DB.readDateFromDB(getData: fillGraph)
            }else{
                fillGraph(data: DB.data!)
            }
            
            
        }
    }
    
    @IBAction func sixMonth(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            
            timeGraphButtons[index].backgroundColor = UIColor.flatBlue()
            index = 2
            
            timeGraphButtons[index].backgroundColor = UIColor.flatPowderBlueColorDark()
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            DB.period = 182
            
            if DB.data == nil {
                DB.readDateFromDB(getData: fillGraph)
            }else{
                fillGraph(data: DB.data!)
            }
        }
    }
    
    @IBAction func nineMonth(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            
            timeGraphButtons[index].backgroundColor = UIColor.flatBlue()
            index = 3
            
            timeGraphButtons[index].backgroundColor = UIColor.flatPowderBlueColorDark()
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            DB.period = 273
           
            
            if DB.data == nil {
                DB.readDateFromDB(getData: fillGraph)
            }else{
                fillGraph(data: DB.data!)
            }
        }
    }
    
    @IBAction func oneYear(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            
            timeGraphButtons[index].backgroundColor = UIColor.flatBlue()
            index = 4
            
            timeGraphButtons[index].backgroundColor = UIColor.flatPowderBlueColorDark()
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            DB.period = 365
           
            
            if DB.data == nil {
                DB.readDateFromDB(getData: fillGraph)
            }else{
                fillGraph(data: DB.data!)
            }
        }
    }
    
    @IBAction func allTime(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            
            timeGraphButtons[index].backgroundColor = UIColor.flatBlue()
            index = 5
            
            timeGraphButtons[index].backgroundColor = UIColor.flatPowderBlueColorDark()
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            DB.period = -1
           
            if DB.data == nil {
                DB.readDateFromDB(getData: fillGraph)
            }else{
                fillGraph(data: DB.data!)
            }
        }
    }
    
    func setTitle(){
           self.title = DB.cryptocurrency.name() + " (" + DB.cryptocurrency.crypto.getSymbol() +  ")"
    }
    
    func getTickerURL()->String{
        return  DB.coinMarket.priceUrl+DB.cryptocurrency.crypto.getId()+"/"
    }
    
    //Mark - SearchDelegate
    //******************************************************************************************\\
    func selectedCryptocurrency(cryp: CryptocurrencyBank) {
        
        //Show progress
       SVProgressHUD.show()
        
        //Clear graph
       candleStickGraph.clear()
        
        //Set selected cryptocurrency
       DB.cryptocurrency.crypto = cryp
      
        //Set cryptocurrency name
       let crypName =  DB.cryptocurrency.name().lowercased()
       DB.coinMarket.crypto = crypName
        
        print(DB.coinMarket.priceUrl)
        //Read data from DB and fill Graph
       DB.readDateFromDB(getData: fillGraph)
        
        //get current price
       getCurrencyValue(url: getTickerURL(),
                         parameters: DB.coinMarket.priceParamerer,
                         updateData: updateCurrencyData)
    }
    
    
    //Mark - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "goToSearch" {
            
            let destinationVC =  segue.destination as! SearchViewController

            destinationVC.delegate = self
             print("Rosario")
            
        }
    }
}

extension Double {
    
    /// Rounds the double to decimal places value
    func rounded(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

