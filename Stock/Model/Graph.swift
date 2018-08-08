//
//  Graph.swift
//  Stock
//
//  Created by Julio Rosario on 7/22/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation
import Charts

struct Graph {
    
    var data: [HistoricalData]?
    
    func dataEntries(data: [Double] )->[BarChartDataEntry] {
   
        let values = (0..<data.count).map {
            (i) -> BarChartDataEntry  in
            
            print("x: \(Double(i))   y: \(data[i])" )
            return BarChartDataEntry(x: Double(i), y: data[i])
            
        }
        return values
    }
    
    
  func getData() -> ChartData{
        
        var entries = [CandleChartDataEntry]()
    
        if let OHLC = data {
            
            //get entries from data
            for i in 0...OHLC.count-1 {
                
                let entry = CandleChartDataEntry(x:Double(i),
                                                 shadowH: OHLC[i].high,
                                                 shadowL: OHLC[i].low,
                                                    open: OHLC[i].open,
                                                   close: OHLC[i].close)
                entries.append(entry)
            }
            
        }
        
        //Set the entries
        let set  = CandleChartDataSet(values: entries, label: "")
    
        set.drawValuesEnabled = false
        set.axisDependency = .left
    
        set.drawIconsEnabled = false
    
        set.shadowColor = .white
        set.shadowWidth = 0.7
    
        set.decreasingColor = UIColor.flatRedColorDark()
        set.decreasingFilled = true
    
        set.increasingColor = UIColor.flatGreen()
        set.increasingFilled = true
    
        set.neutralColor = .blue
        
        return  CandleChartData(dataSet: set)
    }
}
