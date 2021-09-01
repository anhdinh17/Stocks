//
//  APICaller.swift
//  Stocks
//
//  Created by Anh Dinh on 7/25/21.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = "c49egvaad3ieskgqt8o0"
        static let sandboxApiKey = "sandbox_c49egvaad3ieskgqt8og"
        static let baseUrl = "https://finnhub.io/api/v1/"
        // this line used for calculating a day second to used for "news" func
        static let day: TimeInterval = 3600 * 24
    }
    
    // Luôn có thằng quỷ này
    private init(){
        
    }
    
    private enum Endpoint: String {
        case search = "search" // endpoint used for url
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
    
//MARK: - Public - Search
    // This func is to search for 1 stock symbol
    public func search(
        query: String,
        completion: @escaping(Result<SearchResponse,Error>) -> Void){
        
        // this one is to make sure there is no invalid characters within the query of the url
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        // Use Generic request func
        // url paramter is the func "url" to create a url
        request(url: url(
                    for: .search,
                    queryParams: ["q":safeQuery]),
                expecting: SearchResponse.self,
                completion: completion) // the completion of the request func is the same as this search func, so we can use this SYNTAX
    }
    
//MARK: - News func
    // This func is to get the news from 7 days ago till today
    public func news(for type: NewsViewController.`Type`,
                      completion: @escaping (Result<[NewsStory],Error>) -> Void
    ){
        /*
        We have 2 types of news. 1 for general "Top Stories", 1 for specific company.
        That's why we need to switch
        */
        switch type {
        case .topStories:
            request(url: url(for: .topStories, queryParams: ["category" : "general"]),
                    expecting: [NewsStory].self,
                    completion: completion)
        case .company(let symbol):
            let today = Date()
            // time from last 7 days
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            request(url: url(for: .companyNews,
                             queryParams: [
                                "symbol" : symbol,
                                "from" : DateFormatter.newsDateFormatter.string(from: oneMonthBack), // Use extension to convert Date() to String under the form of "YYYY-MM-dd"
                                "to" : DateFormatter.newsDateFormatter.string(from: today)
                             ]),
                    expecting: [NewsStory].self,
                    completion: completion)
        }
        
    }
    
//MARK: - MarketData
    
    // This funcs gets market data for a symbol of stock
    public func marketData(
        for symbol: String,
        numberOfDays: TimeInterval = 7,
        completion: @escaping (Result<MarketDataResponse,Error>)->Void)
    {
        let today = Date().addingTimeInterval(-(Constants.day))
        
        // 1 day before
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        
        // Create a url based on url from finnhub: Stock Candles
        // Pay Attention: "from","to" use TimeInterval form, use Int() to make it whole number.
        let url = url(for: .marketData,
                      queryParams: [
                        "symbol" : symbol,
                        "resolution" : "1",
                        "from" : "\(Int(prior.timeIntervalSince1970))",
                        "to" : "\(Int(today.timeIntervalSince1970))"
                      ])
        
        // request data
        request(url: url,
                expecting: MarketDataResponse.self,
                completion: completion)
    }

//MARK: - URL func
    /* this func is to create a url string
     Có thể xem cả func này là công thức để tạo url string
     */
    private func url(
        for endpoint: Endpoint,
        queryParams: [String: String] = [:] // dictionary
    ) -> URL? {
        
        var urlString = Constants.baseUrl + endpoint.rawValue
        // "https://finnhub.io/api/v1/" + "search"
        
        var queryItems = [URLQueryItem]()
        print("Initial queryItems: \(queryItems)")
        
        // Add any parameters
        for (name, value) in queryParams {
            // SYNTAX để add dictionary to URLQueryItem
            queryItems.append(.init(name: name, value: value))
        }
        print("\n queryItems: \(queryItems)")
        
        // Add token to url
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        print("queryItems after adding token: \(queryItems)")
        
        // Convert query items to suffix string
        // map là chuyển mỗi element thành dạng ví dụ q=apple,token=api key bởi vì queriItems chỉ là 1 array của dictionary
        // joined là gắn các element lại và add "&" vô giữa mỗi element
        // the example of a url string after being created: In this case, end point is "search", q = Apple https://finnhub.io/api/v1/search?q=Apple&token=c49egvaad3ieskgqt8o0
        urlString += "?" + queryItems.map{"\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        print("\n The url string created by url func: \(urlString)")
        
        return URL(string: urlString)
    }
    
//MARK: - Generic API func
    // T is the codable Object(struct) that we normally create to store data from API call
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type, // Expecting is the form of the JSON.For example: Object or array of Object
        completion: @escaping (Result<T, Error>) -> Void
    ){
        guard let url = url else {
            // Invalid URL
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                }else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            
            do {
                // Cái này cũng giống như decode bình thường, expecting: T.Type là struct mà mình muốn convert data into
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
}
