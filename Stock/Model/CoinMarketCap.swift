//
//  CoinMarketCap.swift
//  Stock
//
//  Created by Julio Rosario on 7/28/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//


//TODO Parse HTML and get historical data in an array of double values

import Foundation
import SwiftSoup

class CoinMarketCap {
    
    let crypto = "bitcoin"
    
    //Properties to get current price
    let priceParamerer: [String: String] = ["convert": "USD"]
    let priceUrl = "https://api.coinmarketcap.com/v2/ticker/"
    
    //Start and end date for historical data
    var startDate = "20180727"
    var endDate   = "20180728"
    
    //Properties to get historical data
    private lazy var historicalUrl = "https://coinmarketcap.com/currencies/"+crypto+"/historical-data/?start=" + startDate + "&end=" + endDate
    
    //Months
    let monthLookUp = [1: 31, 2: 28, 3: 31,
                  4: 30, 5: 31, 6: 30,
                  7: 31, 8: 31, 9: 30,
                  10: 31, 11: 30, 12: 31]
    
    let oneWeek = 8
    let threeMonth = 91
    let sixMonth  = 181
    let nineMonth = 273
    let oneYear   = 365
    
    var allTime: Int {
        get{
            let (year,month,day) = getDate()
            
            //Get the number of days from year
            var y =  year - 2013
            y = 365 * y
            
            print("This is \(y)")
            
            //Get the number of days from month
            
            var m = 0
            if month - 4 >= 1 {
                m = abs(month - 4)
                m = monthLookUp[m]!*m
            }
          
           /* var d = 0
            if day - 28 >= 1 {
                d = day - 28
            }*/
            
            return y + m
        }
    }
    
    
    func getHTML(url: String)->String? {
        
        var content:String?
        if let url = URL(string: url) {
           
            do {
                content = try String(contentsOf: url)
            }
            catch {
                print("URL couldn't load")
            }
        }
        else {
            print("The url was bad")
        }
        return content
    }
    
    
    func getHistory(html: String)-> [HistoricalData]{
        
        var hloc = [HistoricalData]()
        
        do {
            
            //Get the table containing crypto data
            let doc: Document    = try SwiftSoup.parse(html)
            let table            = try doc.getElementsByTag("table")
            
            let tbodyDoc         = try SwiftSoup.parseBodyFragment(table.outerHtml())
            let elements         = try tbodyDoc.getElementsByTag("td").array()
            
            print(elements.count-1)
            //Fill the array with the data
            var i = 0
            while ( i < elements.count){
                let data = HistoricalData()
                
                data.date       = try elements[0 + i].html()
                data.open       = Double(try  elements[1 + i].html())
                data.high       = Double(try  elements[2 + i].html())
                data.low        = Double(try  elements[3 + i].html())
                data.close      = Double(try  elements[4 + i].html())
                data.volume     = try  elements[5 + i].html()
                data.martketCap = try  elements[6 + i].html()
                
                i += 7
                hloc.append(data)
            }
            hloc.reverse()
            
            for i in hloc {
                print("\(i.date)  \(i.open)  \(i.high)  \(i.low)  \(i.close)  \(i.volume)  \(i.martketCap)")
            }
        }
        catch {
            print(error)
        }
        
        return hloc
    }
    
    
    //MARK: -Format Text
    /**************************************************************************/
    func getDate()-> (Int,Int,Int){
        
        let calendar = Date().description
        
        let year  = Int(getSubString(str: calendar, start: 0, end: 21))!
        let month = Int(getSubString(str: calendar, start: 5, end: 18))!
        let day   = Int(getSubString(str: calendar, start: 8, end: 15))!
        
        return (year,month,day)
    }
    
    func getTime()->(Int,Int,Int){
        let calendar = Date().description
        
        print(calendar)
        
        let hour = Int(getSubString(str: calendar, start: 11, end: 12))!
        let min  = Int(getSubString(str: calendar, start: 14, end: 9))!
        let sec  = Int(getSubString(str: calendar, start: 17, end: 6))!
        
        return (hour,min,sec)
    }
    
    func getSubString(str: String, start: Int, end: Int) -> String  {
        
        let begin = str.index(str.startIndex, offsetBy: start)
        let final = str.index(str.endIndex, offsetBy: -end)
        let range = begin..<final
        
        let mySubstring = str[range]
        
        return String(mySubstring)
    }
    
    
    func getUrl(y: Int, m: Int, d: Int)->String {
        
        
        let (year,month,day) = getDate()
        
        var endYear = 0
        var endMonth = 0
        var endDay  = 0
        
        //Check that day is valid
        if day - d < 1 {
           endMonth =  month - 1
            endDay = monthLookUp[month]! - (day-d)
        }
        else{
            endDay = day-d
        }
        
        //Check that month is valid
        if month - m < 1 {
            endYear = year-1
            endMonth = 12 + (month-m)
        }else{
            endMonth = month-m
            endYear = year - y
        }
        
      
        endDate     = getFormattedDate(year: year, month: month, day: day)
        startDate   = getFormattedDate(year: endYear, month: endMonth, day: endDay)
        
        print(historicalUrl)
        
        return historicalUrl
    }
    
    func getAllTimeUrl()->String {
          let (year,month,day) = getDate()
        
          endDate = getFormattedDate(year: year, month: month, day: day)
          startDate = "20130428"
        
          print(historicalUrl)
        
          return historicalUrl
    }
   
    func getFormattedDate(year: Int, month: Int, day: Int) -> (String) {
        
        if month < 10 && day < 10{
            return "\(year)0\(month)0\(day)"
            
        }
        else if month < 10 {
            return  "\(year)0\(month)\(day)"
            
        }
        else if day < 10 {
           return  "\(year)\(month)0\(day)"
           
        }
        else {
           return "\(year)\(month)\(day)"
        }
    }
}
