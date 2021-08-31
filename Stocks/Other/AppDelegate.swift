//
//  AppDelegate.swift
//  Stocks
//
//  Created by Anh Dinh on 7/24/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        APICaller.shared.search(query: "Apple") { result in
//            switch result {
//            case .success(let response):
//                print(response.result)
//            case .failure(let error):
//                print(error)
//            }
//        }
        
        debug()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

    private func debug(){
//        APICaller.shared.news(for: .company(symbol: "MSFT")) { result in
//            switch result {
//            case .success(let news):
//                print(news.count)
//            case .failure(let error):
//                break
//            }
//        }
        
//        var companiesSymbols = PersistenceManager.share.watchList
//
//        print(companiesSymbols)
//
//        APICaller.shared.marketData(for: "AAPL") { result in
//            switch result {
//            case .success(let data):
//                var candleSticks = data.candleSticks
//            case .failure(let error):
//                print(error)
//            }
//        }
        
        
        
    }

}

