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
    }
    
    // Luôn có thằng quỷ này
    private init(){
        
    }
    
    private enum Endpoint: String {
        case search = "search"
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
    
//MARK: - Public
    
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

//MARK: - URL func
    /* this func is to create a url string
     Có thể xem cả func này là công thức để tạo generic url string
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
        urlString += "?" + queryItems.map{"\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        print("\n \(urlString)")
        
        return URL(string: urlString)
    }
    
//MARK: - Generic API func
    // T is the codable Object(struct) that we normally create to store data from API call
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
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
