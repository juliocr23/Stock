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

class ViewController: UIViewController{
    
    
    //TODO when a button is pressed for a different graph I get the same url. ????
    
    
    //Crypto currency and graph being shown
    var cryptoCurrency = Cryptocurrency(crypto: .Bitcoin)
    var chart = Graph()
    
    //Get Data from coinMarketCap
    lazy var coinMarket = CoinMarketCap()
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
        timeGraphButtons[index].backgroundColor = UIColor.lightGray
        
        getCurrencyValue(url: getTickerURL(),
                         parameters: coinMarket.priceParamerer,
                         updateData: updateCurrencyData)
        
        candleStickGraph.setNeedsDisplay()
        
        let url = coinMarket.getUrl(y: 0, m: 0, d: coinMarket.oneWeek)
        updateGraph(url: url)
        
    }
    
    //MARK: - Get Crypto Value
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
    func updateCurrencyData(json: JSON){
        
        cryptoCurrency.price              = json["data"]["quotes"]["USD"]["price"].doubleValue
        cryptoCurrency.volume             = json["data"]["quotes"]["USD"]["volume_24h"].intValue
        cryptoCurrency.marketCap          = json["data"]["quotes"]["USD"]["market_cap"].doubleValue
        cryptoCurrency.change             = json["data"]["quotes"]["USD"]["percent_change_24h"].doubleValue
        cryptoCurrency.circulatingSupply  = json["data"]["circulating_supply"].intValue
        cryptoCurrency.maxSupply          = json["data"]["max_supply"].intValue
        cryptoCurrency.rank               = json["data"]["rank"].intValue
        
    }
    
   
    func updateUI(data: ChartData){
        
        var display = cryptoCurrency.getDisplayFormat(number: Double(cryptoCurrency.volume!))
        volume.text = display
        
        display = cryptoCurrency.getDisplayFormat(number: Double(cryptoCurrency.marketCap!))
        marketCap.text = display
        
        display =  cryptoCurrency.getDisplayFormat(number: Double(cryptoCurrency.maxSupply!))
        maxSupply.text = display
        
        display = cryptoCurrency.getDisplayFormat(number: Double(cryptoCurrency.circulatingSupply!))
        circulatingSupply.text = display
        
        rank.text = "Rank " + String(cryptoCurrency.rank!)
        price.text = "$" + String(cryptoCurrency.price!) + " USD"
        
        candleStickGraph.data = data
        candleStickGraph.leftAxis.enabled = false
        candleStickGraph.rightAxis.enabled = false
        candleStickGraph.xAxis.enabled = false
        SVProgressHUD.dismiss()
        
    }
    
    func updateGraph(url: String){
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let html =  self.coinMarket.getHTML(url: url)
            
            if html != nil {
                
                self.chart.data = self.coinMarket.getHistory(html: html!)
                
                let data  =  self.chart.getData()
                DispatchQueue.main.async {
                    self.updateUI(data: data)
                }
            }
        }
    }
    
    
    func getTickerURL()->String{
        return  coinMarket.priceUrl+cryptoCurrency.crypto.getId()+"/"
    }
    
    //MARK: - Graph Events
    /**************************************************************************/
    @IBAction func oneWeek(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            
            timeGraphButtons[index].backgroundColor = UIColor.white
            index = 0
            timeGraphButtons[index].backgroundColor = UIColor.lightGray

            
            candleStickGraph.clear()
            
            SVProgressHUD.show()
            
            let url = coinMarket.getUrl(y: 0, m: 0, d: 7)
            updateGraph(url: url)
        }
    }
    
    @IBAction func threeMonth(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            timeGraphButtons[index].backgroundColor = UIColor.white
            index = 2
            timeGraphButtons[index].backgroundColor = UIColor.lightGray
            
            candleStickGraph.clear()
            
            SVProgressHUD.show()
            let url = coinMarket.getUrl(y: 0, m: 3, d:0 )
            updateGraph(url: url)
        }
        
        
    }
    
    @IBAction func sixMonth(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            timeGraphButtons[index].backgroundColor = UIColor.white
            index = 3
            timeGraphButtons[index].backgroundColor = UIColor.lightGray
            
            candleStickGraph.clear()
            
            SVProgressHUD.show()
            let url = coinMarket.getUrl(y: 0, m: 6, d: 0)
            updateGraph(url: url)
        }
    }
    
    @IBAction func nineMonth(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            
            timeGraphButtons[index].backgroundColor = UIColor.white
            index = 4
            timeGraphButtons[index].backgroundColor = UIColor.lightGray
           
            candleStickGraph.clear()
            
            SVProgressHUD.show()
            let url = coinMarket.getUrl(y: 0, m: 9, d: 0)
            updateGraph(url: url)
        }
    }
    
    @IBAction func oneYear(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            
            timeGraphButtons[index].backgroundColor = UIColor.white
            index = 5
            timeGraphButtons[index].backgroundColor = UIColor.lightGray
            candleStickGraph.clear()
            
            SVProgressHUD.show()
            let url = coinMarket.getUrl(y: 1, m: 0, d: 0)
            updateGraph(url: url)
        }
    }
    
    @IBAction func allTime(_ sender: UIButton) {
        
        if timeGraphButtons[index] != sender {
            
            timeGraphButtons[index].backgroundColor = UIColor.white
            index = 6
            timeGraphButtons[index].backgroundColor = UIColor.lightGray
            
            candleStickGraph.clear()
            
            SVProgressHUD.show()
            let url = coinMarket.getAllTimeUrl()
            updateGraph(url: url)
        }
    }
}

