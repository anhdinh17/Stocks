//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Anh Dinh on 7/25/21.
//

import Foundation

final class PersistenceManager {
    static let share = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchListKey = "watchlist"
    }
    
    private init(){
        
    }
    
    // watchList is an array of companies symbols
    public var watchList: [String] {
        // if user NOT onboarded yet, set it to be True and run setUpDefaults()
        if !hasOnboarded {
            userDefaults.set(true,forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        
        // return a String array từ key "watchlist" (tạo ra ở setUpDefaults)
        return userDefaults.stringArray(forKey: Constants.watchListKey) ?? [String]()
    }
    
    public func addToWatchlist() {
        
    }
    
    public func removeFromWatchlist(){
        
    }
    
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    // This func: create an array with symbols of companies, write companies full name into UserDefaults.
    private func setUpDefaults(){
        // a dictionary
        let map: [String : String] = [
            "AAPL" : "Apple Inc.",
            "MSFT" : "Microsoft Corporation",
            "SNAP" : "Snap Inc.",
            "GOOG" : "Alphabet",
            "AMZN" : "Amazon.com, Inc.",
            "WORK" : "Slack Technologies",
            "FB" : "Facebook Inc.",
            "NVDA" : "Nvidia Inc.",
            "NKE" : "Nike",
            "PINS" : "Pinterest Inc."
        ]
        
        // tách key ra rồi gôm keys lại thành 1 array
        let symbols = map.keys.map{$0}
        // write array ở trên vô UserDefaults key: watchlist ----> "watchlist" variable
        userDefaults.set(symbols, forKey: Constants.watchListKey)
        
        for (symbol,name) in map {
            // Write từng thằng name vô UserDefaults
            userDefaults.set(name, forKey: symbol)
        }
        
    }
}
