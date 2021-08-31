//
//  MarketDataResponse.swift
//  Stocks
//
//  Created by Anh Dinh on 8/27/21.
//

import Foundation

struct MarketDataResponse: Codable {
    let open : [Double]
    let close : [Double]
    let high : [Double]
    let low : [Double]
    let status : String
    let timestamps : [TimeInterval]
    
    /*
     NEW TECHNIQUE:
     With this technique below, Swift will match the variables name we create above with the ones from JSON: "o", "c", "h", "l", "s", "t".
     */
    enum CodingKeys: String, CodingKey {
        case open = "o"
        case close = "c"
        case high = "h"
        case low = "l"
        case status = "s"
        case timestamps = "t"
    }
    
    // computed variable
    // Có nghĩa mỗi lần tạo 1 var "candleSticks", cả cái process này sẽ exec
    var candleSticks: [CandleStick] {
        var result = [CandleStick]()
        
        // với mỗi index, tạo 1 struct CandleStick và add vào "result" array
        for index in 0..<open.count {
            result.append(
                // create an object of CandleStick
                .init(date: Date(timeIntervalSince1970: timestamps[index]), // convert TimeInterval to Date()
                      high: high[index],
                      low: low[index],
                      open: open[index],
                      close: close[index])
            )
        }
        
        var sortedData = result.sorted(by: {$0.date > $1.date})
        print("SortedData: \(sortedData[0])")
        print("SortedData: \(sortedData[1])")
        print("SortedData: \(sortedData[2])")
        
        return sortedData
    }
}

struct CandleStick {
    let date: Date
    let high: Double
    let low: Double
    let open: Double
    let close: Double
}
