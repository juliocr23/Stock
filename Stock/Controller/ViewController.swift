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

class ViewController: UIViewController, SearchDelegate {
    
    var crypto = Cryptocurrency(name: "Bitcoin Cash")
    
    //CoinMarket model
    var coinMarket = CoinMarketCap()
    
    //Graph model
    var chart = Graph()
    
    //Reference to firestore database
    var firebaseDB: Firestore!
    var docRef: DocumentReference {
        get {
            return firebaseDB.collection("cryptocurrencies").document(crypto.name)
        }
    }
    
    //data from firebase
    var data : [String: [String: Double]]?
    
    var graphIndex = 0
    
    var period = 7
    
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
        
        abjustConstraints()
        
        SVProgressHUD.show()
        
        configureDB()
        
        getActiveCurrencies(url: "https://api.coinmarketcap.com/v2/listings/", setData: getCryptoID)
        
        readDataFromDB(getData: fillGraph)
    }
    

    func test(data: [String: [String: Double]]){
        print(sort(data: data))
    }
    
    
    //MARK: - Parse JSON
    /**************************************************************************/
    
    func getCurrentPrice(url: String, parameters: [String: String], updateData: @escaping (JSON) -> Void) {
        
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
    
    func getActiveCurrencies(url: String, setData:  @escaping (JSON) -> Void ) {
       
        Alamofire.request(url, method: .get).responseJSON {
            response in
            
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                
                setData(json)
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    func getCryptoID(json: JSON) {
        
        let dict = Dictionary(keyValuePairs:json["data"].arrayValue.map{($0["name"].stringValue, $0["id"].stringValue)})
        let key  = crypto.name
        
        if let id =  dict[key] {
            
            getCurrentPrice(url: coinMarket.priceUrl+id + "/",
                            parameters: coinMarket.priceParamerer,
                            updateData: updateCurrencyData)
        } else{
            print("Key: " + key + " was not found")
        }
    
    }
    
    //Mark: - Update labels
    /**************************************************************************/
   func updateCurrencyData(json: JSON){
    
        crypto.name               = json["data"]["name"].stringValue
        crypto.symbol             = json["data"]["symbol"].stringValue
        crypto.price              = json["data"]["quotes"]["USD"]["price"].doubleValue.rounded(places: 2)
        crypto.volume             = json["data"]["quotes"]["USD"]["volume_24h"].intValue
        crypto.marketCap          = json["data"]["quotes"]["USD"]["market_cap"].doubleValue
        crypto.change             = json["data"]["quotes"]["USD"]["percent_change_1h"].doubleValue
        crypto.circulatingSupply  = json["data"]["circulating_supply"].intValue
        crypto.maxSupply          = json["data"]["max_supply"].intValue
        crypto.rank               = json["data"]["rank"].intValue
    
        
        updateUI()
    }
    
    func updateUI(){
        
        var display = getDisplayFormat(number: Double(crypto.volume))
        volume.text = display
        
        display =  getDisplayFormat(number: Double(crypto.marketCap))
        marketCap.text = display
        
        if crypto.maxSupply == 0 {
            maxSupply.text = "N/A"
        }else {
            display = getDisplayFormat(number: Double(crypto.maxSupply))
            maxSupply.text = display
        }
        
        display =  getDisplayFormat(number: Double(crypto.circulatingSupply))
        circulatingSupply.text = display
        
        percentChange.text = "(\(crypto.change)%) this hour"
        
        rank.text = "Rank " + String(crypto.rank)
        price.text = "$" + String(crypto.price) + " USD"
        
        icon.image = UIImage(named: crypto.name)
        icon.backgroundColor = UIColor.flatBlue()
    }
    
    //MARK: - Update Graph
    /****************************************************************************************/
    func fillGraph(data: [String: [String: Double]]){
        
        let sortedKeys = sort(data: data)
        chart.data = [HistoricalData]()
        
        //Read all Data from sorted keys
        if period == -1{
           period = sortedKeys.count
        }
        
        for i in 0...period-1 where sortedKeys.count >= period {
            
            let key = sortedKeys[i]
            let temp = data[key]
            
            let historicalData = HistoricalData(date: key,
                                                open: temp!["open"]!,
                                                high: temp!["high"]!,
                                                low:  temp!["low"]!,
                                                close: temp!["close"]!)
           chart.data?.append(historicalData)
        }
        
        updateGraph()
    }
    
    func updateGraph(){
        
        candleStickGraph.setNeedsDisplay()
        candleStickGraph.data = chart.getData()
        candleStickGraph.leftAxis.enabled = false
        candleStickGraph.rightAxis.enabled = false
        candleStickGraph.xAxis.enabled = false
        
        setTitle()
        SVProgressHUD.dismiss()
    }
    
    
    //MARK: - Graph Events
    /**************************************************************************/
    @IBAction func oneWeek(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            print("one week")
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 0
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()

            
            candleStickGraph.clear()
            SVProgressHUD.show()
            
             period = 7
            
            if  data == nil {
               readDataFromDB(getData: fillGraph)
            }else{
                fillGraph(data: data!)
            }
        }
    }
    
    @IBAction func threeMonth(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 1
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            
            
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            period = 90
            
            if  data == nil {
                readDataFromDB(getData: fillGraph)
            }else{
                fillGraph(data: data!)
            }
        }
    }
    
    @IBAction func sixMonth(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
              print("six months")
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 2
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            period = 182
            
            if   data == nil {
               readDataFromDB(getData: fillGraph)
            }else{
                fillGraph(data: data!)
            }
        }
    }
    
    @IBAction func nineMonth(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
             print("9 months")
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 3
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            period = 273
           
            
            if  data == nil {
               readDataFromDB(getData: fillGraph)
            }else{
                fillGraph(data: data!)
            }
        }
    }
    
    @IBAction func oneYear(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
             print("one year")
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 4
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            candleStickGraph.clear()
            SVProgressHUD.show()
            
             period = 365
           
            
            if data == nil {
                readDataFromDB(getData: fillGraph)
            }else{
                fillGraph(data: data!)
            }
        }
    }
    
    @IBAction func allTime(_ sender: UIButton) {
        
        if timeGraphButtons[graphIndex] != sender {
            
             print("all time")
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatBlue()
            graphIndex = 5
            
            timeGraphButtons[graphIndex].backgroundColor = UIColor.flatPowderBlueColorDark()
            candleStickGraph.clear()
            SVProgressHUD.show()
            
            period = -1
           
            if data == nil {
                readDataFromDB(getData: fillGraph)
            }else{
                fillGraph(data: data!)
            }
        }
    }
    
    
    //MARK: - Firebase/Firestore
    /******************************************************************************************/
    func configureDB(){
        
        FirebaseApp.configure()
        
        firebaseDB = Firestore.firestore()
        let settings = firebaseDB.settings
        settings.areTimestampsInSnapshotsEnabled = true
        firebaseDB.settings = settings
        
        docRef.addSnapshotListener(includeMetadataChanges: true) { (document, err) in
            
            guard let doc = document else {
                print("Error fetching document: \(err!)")
                return
            }
            
            if !doc.metadata.hasPendingWrites {
                print("Hurra")
            }
        }
    }
    
    /*func writeDataToFirebase(path: String) {
       
        DispatchQueue.global(qos: .userInteractive).async {
            
            //Get html document
            let page =  self.coinMarket.getHTML(url: path)
            
            if page != nil {
                
                //Parse data from html
                let data = self.coinMarket.getHistory(html: page!)
                
                //Put data in DB
                for value in data {
                    self.docRef.setData(value.dictionary , merge: true)
                }
                self.docRef.addSnapshotListener(includeMetadataChanges: true, listener: { (document, error) in
                    
                    if let doc = document {
                        if !doc.metadata.hasPendingWrites {
                            print("Data has been written to Server")
                            self.readDataFromDB(getData: self.fillGraph)
                        }
                    }
                })
            }
        }
    }*/
    
    func readDataFromDB(getData: @escaping ([String: [String: Double]]) -> Void) {
        
        //Get Data from document
        docRef.getDocument { (document, err) in
            
            //Get document if not nil
            if let doc = document, doc.exists {
                
                self.data = doc.data() as? [String: [String: Double]]
                
                getData(self.data!)
            }
            else {
                print("There was an error Getting document")
                print(err.debugDescription)
            }
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
        let sorted = convertedArray.sorted(by:
        {$0.compare($1) == .orderedAscending })
        
        var ready = [String]()
        
        //Convert date to String
        for value in sorted {
            ready.append(dateFormatter.string(from:value))
        }
        
        return ready
    }
    
    func setTitle(){
           self.title =  crypto.name + " (" + crypto.symbol +  ")"
    }
    
    //MARK: - SearchDelegate
    //******************************************************************************************\\
    func selectedCryptocurrency(name:  String) {
        
        //Show progress
        SVProgressHUD.show()
        
        setTitle()
        
        //Clear graph
        candleStickGraph.clear()
      
        //Set cryptocurrency name
        crypto.name = name
        
        let crypName = name.lowercased()
        coinMarket.crypto = crypName
        
        //Read data, check for updates and fill graph.
        readDataFromDB(getData: fillGraph)
        
        //get current price
         getActiveCurrencies(url: "https://api.coinmarketcap.com/v2/listings/", setData: getCryptoID)
    }
    
    
    //MARK: - UpdateData
    /**************************************************************************************/
   /* func updateData(data: [String: [String: Double]]){
      
        //Sort Data from DB
       let sortedKeys = sort(data: data)
    
      //Get yesterday and last entry from DB
       var yesterday  = coinMarket.getYesterday()
       var lastEntry  = sortedKeys[sortedKeys.count-1]
        
        //Format yesterday and last entry int yyyyMMdd
       yesterday = coinMarket.yyyyMMdd(str: yesterday)
       lastEntry = coinMarket.yyyyMMdd(str: lastEntry)
        
        
         //Get year,month and day from yesterday
        let (yearFromYesterday,
             monthFromYesterday,
             dayFromYesterday) = getYearMonthDayInt(text: yesterday)
        
         //Get year, month and day from last entry
        let (yearFromLastEntry,
             monthFromLastEntry,
             dayFromLastEntry) = getYearMonthDayInt(text: lastEntry)
        
      
        //Check if there is an update
        let needAnUpdate = yearFromYesterday  > yearFromLastEntry  ||
                           monthFromYesterday > monthFromLastEntry ||
                           dayFromYesterday   > dayFromLastEntry
        
        if needAnUpdate {
            print("There is an update")
            
            coinMarket.startDate = lastEntry
            coinMarket.endDate   = yesterday
            
            print("Url: " + coinMarket.historicalUrl)
            writeDataToFirebase(path: coinMarket.historicalUrl)
            
        }else{
            print("There is no update")
            fillGraph(data: data)
        }
    }*/
    
    /*func getYearMonthDayInt(text: String)->(Int,Int,Int) {
        let year     = Int(coinMarket.getSubString(str: text, start: 0, end: 4))!
        let month    = Int(coinMarket.getSubString(str: text, start: 4, end: 2))!
        let day      = Int(coinMarket.getSubString(str: text, start: 6, end: 0))!
        
        return (year,month,day)
    }*/
    
    
    
    //MARK - Segues
     /****************************************************************************************/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "goToSearch" {
            
            let destinationVC =  segue.destination as! SearchViewController
            destinationVC.delegate = self
        }
    }
    
    //MARK - Request html
     /****************************************************************************************/
   /* func requestHTML(url: String, getHTML: @escaping (String) -> Void){
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let html =  self.coinMarket.getHTML(url: url)
            
            if html != nil {
                getHTML(html!)
            }else{
                print("HTML is nil")
            }
        }
    }*/
    
    func abjustConstraints(){
        
        if   UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            
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
    
    func getDisplayFormat(number: Double) -> String {
        
        let num = abs(Double(number))
        let sign = (number < 0) ? "-" : ""
        
        switch number {
            
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 2)
            return "$\(sign)\(formatted) B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 2)
            return "$\(sign)\(formatted) M"
            
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 2)
            return "$\(sign)\(formatted) K"
            
        case 0...:
            return "$\(number)"
            
        default:
            return "$\(sign)\(number)"
            
        }
    }
}

//MARK: double methods
extension Double {
    
    /// Rounds the double to decimal places value
    func rounded(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}


extension Dictionary {
    public init(keyValuePairs: [(Key, Value)]) {
        self.init()
        for pair in keyValuePairs {
            self[pair.0] = pair.1
        }
    }
}

//Mark: Device version
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}

