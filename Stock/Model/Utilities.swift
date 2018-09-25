//
//  Utilities.swift
//  Stock
//
//  Created by Julio Rosario on 8/25/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class Utilities {
    
    static func getDate()-> (Int,Int,Int){
        
        let calendar = Date().description
        
        let year  = Int(getSubString(str: calendar, start: 0, end: 21))!
        let month = Int(getSubString(str: calendar, start: 5, end: 18))!
        let day   = Int(getSubString(str: calendar, start: 8, end: 15))!
        
        return (year,month,day)
    }
    
    static func getYesterday()->String{
        
        //Get the date of yesterday
        var (y,m,d) = getDate()
        d -= 1
        
        var month = ""
        var day   = ""
        let year  = "\(y)"
        
        if m < 10 {
            month = "0\(m)"
        } else {
            month = "\(m)"
        }
        
        if d < 10 {
            day = "0\(d)"
        } else{
            day = "\(d)"
        }
        
        let strDate = "\(month)-\(day)-\(year)"
        
        //Converte strDate to a date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        let date =  dateFormatter.date(from: strDate)
        
        //Change date format to MMM d, yyyy
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let goodDate = dateFormatter.string(from: date!)
        
        return goodDate
    }
    
    static func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    static func getSubString(str: String, start: Int, end: Int) -> String  {
        
        let begin = str.index(str.startIndex, offsetBy: start)
        let final = str.index(str.endIndex, offsetBy: -end)
        let range = begin..<final
        
        let mySubstring = str[range]
        
        return String(mySubstring)
    }
    
     static func yyyyMMdd(str: String) -> String {
     
         //Converte strDate to a date object
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd"
         dateFormatter.timeZone = TimeZone.current
         dateFormatter.locale = Locale.current
         let date =  dateFormatter.date(from: str)
        
         //Change date format to MMM d, yyyy
         dateFormatter.dateFormat = "yyyyMMdd"
         let goodDate = dateFormatter.string(from: date!)
        
         return goodDate
     }

    static func getYearMonthDayInt(text: String)->(Int,Int,Int) {
        let year     = Int(getSubString(str: text, start: 0, end: 4))!
        let month    = Int(getSubString(str: text, start: 4, end: 2))!
        let day      = Int(getSubString(str: text, start: 6, end: 0))!
        
        return (year,month,day)
    }

   static func sort(data : [String:[String: Double]]) ->[String]{
        
        let keys = Array(data.keys)
        var convertedArray: [Date] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
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
    
    static func getJsonRequest(url: String, parameters: [String: String], function: @escaping (JSON) -> Void) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            
            if response.result.isSuccess {
                
                let json = JSON(response.result.value!)
                function(json)
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
   static func getDisplayFormat(number: Double) -> String {
        
        let num = abs(Double(number))
        let sign = (number < 0) ? "-" : ""
        
        switch number {
            
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 2)
            return "\(sign)\(formatted) B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 2)
            return "\(sign)\(formatted) M"
            
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 2)
            return "\(sign)\(formatted) K"
            
        case 0...:
            return "\(number)"
            
        default:
            return "\(sign)\(number)"
            
        }
    }
}

public extension String {
    func contentsOrBlank()->String {
        if let path = Bundle.main.path(forResource:self , ofType: nil) {
            do {
                let text = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                return text
            } catch { print("Failed to read text from bundle file \(self)") }
        } else { print("Failed to load file from bundle \(self)") }
        return ""
    }
}

//MARK: double methods
public extension Double {
    
    /// Rounds the double to decimal places value
    func rounded(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

public extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}


public extension Dictionary {
    public init(keyValuePairs: [(Key, Value)]) {
        self.init()
        for pair in keyValuePairs {
            self[pair.0] = pair.1
        }
    }
}

//Mark: Device version
public extension UIDevice {
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

public extension UIImage {
    func resize(width: Int,height: Int) -> UIImage? {
        
        let size           = CGSize(width: width, height: height)
        let hasAlpha       = true
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}







