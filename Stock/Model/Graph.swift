//
//  Graph.swift
//  Stock
//
//  Created by Julio Rosario on 7/22/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation
import Charts

class Graph {
    
    var data: [HistoricalData]?
    
    func dataEntries(data: [Double] )->[BarChartDataEntry] {
   
        let values = (0..<data.count).map {
            (i) -> BarChartDataEntry  in
            
            print("x: \(Double(i))   y: \(data[i])" )
            return BarChartDataEntry(x: Double(i), y: data[i])
            
        }
        return values
    }
    
    func getData()->ChartData{
        return getCandleChartData()
    }
    
    
    func getCandleChartData() -> CandleChartData{
        
        var entries = [CandleChartDataEntry]()
        
        if let hloc = data{
            
            for i in 0...hloc.count-1 {
                
                let entry = CandleChartDataEntry(x:Double(i), shadowH: hloc[i].high,
                                                 shadowL: hloc[i].low, open: hloc[i].open,
                                                 close: hloc[i].close)
                entries.append(entry)
            }
        }
        
        let set  = CandleChartDataSet(values: entries, label: "Data Set")
        set.drawValuesEnabled = false
        return  CandleChartData(dataSet: set)
    }
    
    
    /*func getBarChartData() -> BarChartData{

        var entries = [BarChartDataEntry]()
         
         for i in 0...price.count-1 {
            let entry = BarChartDataEntry(x: Double(i), y:price[i])
            entries.append(entry)
         }
         
         let dataSet = BarChartDataSet(values: entries, label: "Volume")
         let data = BarChartData(dataSets: [dataSet])
        
        return data
    }*/
}
