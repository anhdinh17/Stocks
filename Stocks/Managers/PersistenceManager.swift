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
        
    }
    
    private init(){
        
    }
    
    public var watchList: [String] {
        return []
    }
    
    public func addToWatchlist() {
        
    }
    
    public func removeFromWatchlist(){
        
    }
    
    private var hasOnboarded: Bool {
        return false
    }
}
