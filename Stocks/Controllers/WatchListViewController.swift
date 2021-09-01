//
//  ViewController.swift
//  Stocks
//
//  Created by Anh Dinh on 7/24/21.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {

    // this one is used for reducing the number of times we call API search() when we hit keyboard
    private var searchTimer: Timer?
    
    // Floating panel
    private var panel: FloatingPanelController?
    
    // TableView
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    // ????? Model
    private var watchlistMap: [String : [CandleStick]] = [:]
    
    // ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .systemBackground
        
        setUpSearchController()
        
        setUpTitleView()
        
        setUpTableView()
        
        fetchWatchlistData()
        
        setUpFoatingPanel()
    }
    
//MARK: - Functions
    private func fetchWatchlistData(){
        // "symbols" is an array of companies' symbols
        // ["FB", "GOOG", "PINS", "AAPL", "MSFT", "AMZN", "WORK", "NVDA", "NKE", "SNAP"]
        var symbols = PersistenceManager.share.watchList
        symbols = symbols.filter({$0 != "WORK"})
        
        print("Symbols: \n\n \(symbols)")
        
        let group = DispatchGroup()
        
        for symbol in symbols {
            group.enter()
            
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    // data is an object of MarketDataResponse
                    
                    print(symbol)
                    // an array of [CandleStick]
                    var candleSticks = data.candleSticks
                    
                    // Mình muốn 1 symbol ứng với 1 array của [CandleSticks]
                    // hay có nghĩa là 1 symbol ứng với 1 data market của nó
                    self?.watchlistMap[symbol] = candleSticks
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        //self?.print("This is WatchListMap: \(watchlistMap)")
      
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
        
    }
    
    private func createViewModels(){
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        // With each symbol and its [CandleSticks]:
        for (symbol,candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            
            viewModels.append(.init(symbol: symbol,
                                    // get company name from UserDefaults, we add them in PersistenceManager.
                                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company Name",
                                    price: getLatestClosingPrice(from: candleSticks),
                                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                                    changePercentage: "\(changePercentage)")
            )
        }
        
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        
        // latest closing price and prior closing price, data from candleSticks
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else {
            return 0
        }
        
        print("\(symbol)---Current: \(data[0].date)--\(latestClose) | Prior: \(priorClose)")
        
        let diff = 1 - (priorClose/latestClose)
        
        print("\(symbol): \(diff)%")
        
        return diff
    }
    
    // get closing price from the first element of [CandleStick]
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        
        return "\(closingPrice)"
    }
    
    private func setUpTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpSearchController(){
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self // set cai nay để xài delegate func của SearchResultViewController
        
        let searchVC = UISearchController(searchResultsController: resultVC)
        // this one is for the protocol UISearchResultsUpdating
        searchVC.searchResultsUpdater = self
        
        // add search bar to Nav Bar
        navigationItem.searchController = searchVC
    }
    
    private func setUpTitleView(){
        // Tạo 1 UIView để add vô VC này
        // Cách tạo UIView có sẵn frame
        let titleView = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: view.width,
                                             height: navigationController?.navigationBar.height ?? 100))
        
        // Dòng này như là add titleView vô Navigation Bar, giống như addSubView, ko có dòng này thì titleView ko hiện lên nav Bar
        navigationItem.titleView = titleView
        
        // Tạo 1 label để add vô UIView này
        let label = UILabel(frame: CGRect(x: 10,
                                          y: 0,
                                          width: titleView.width - 20,
                                          height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 40, weight: .medium)
        
        // add label to titleView
        titleView.addSubview(label)
        
    }

//MARK: - Floating panel
    private func setUpFoatingPanel(){
        // this vc will be added to the panel
        let vc = NewsViewController(type: .company(symbol: "FB"))
        
        // Create a panel and add it to this VC
        let panel = FloatingPanelController(delegate: self) // syntax này cũng để set this VC là delegate để xài delegate func, ko xài cách này thì set panel.delegate = self cũng giống nhau
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.addPanel(toParent: self)
        panel.set(contentViewController: vc) // add NewsViewController() to floating panel
        panel.track(scrollView: vc.tableView)
    }

}

//MARK: - Search Controller
extension WatchListViewController: UISearchResultsUpdating {
    // Every time we hit keyboard, this func updates the contents of the search bar
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              // cast down to SearchResultsVC để xài VC này to display searching results.
              // dòng này là 1 trong những bước của process tạo search bar.
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              // trim out all white spaces and the text is not empty
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        /*
        The whole timer thing means: everytime user hit a key on keyboard, it resets the timer then kick off new timer to search for API.
         Khi user bấm 1 phím trên keyboard, 0.3 giây sau API call sẽ chạy, vậy nếu khoảng thời gian giữa mỗi lần bấm từ 0.3 trở xuống thì API call sẽ không chạy. Vậy sẽ giúp làm giảm số lần gọi API
        */
        
        // Reset timer
        searchTimer?.invalidate()
        
        // Kick off new timer
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            // Call API to search
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response): // response là 1 SearchResponse Object
                    DispatchQueue.main.async {
                        // Update results controller
                        resultsVC.update(with: response.result)
                    }
                case.failure(let error):
                    // update the table view with empty array
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                    print(error)
                }
            }
        })
    }
    
}

//MARK: - Protocol Func from SearchResultsViewController
extension WatchListViewController: SearchResultsViewControllerDelegate {
    
    func searchResultsViewControllerDelegate(searchResult: SearchResult) {
        // Resign keyboard:
        // because search bar is in navigation bar, so we use this syntax
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        // Present Stock details
        /* Cách 1:
         let vc = StockDetailsViewController()
         vc.title = searchResult.description
         navigationController?.pushViewController(vc, animated: true)
        */
       
        // Cách 2:
        let vc = StockDetailsViewController()
        vc.title = searchResult.description
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }

}

//MARK: - Delegate of FloatingPanel
extension WatchListViewController: FloatingPanelControllerDelegate {
    // This func is to track the state of the floating panel, when it's tip, half or full screen.
    func floatingPanelDidChangePosition(_ fpc: FloatingPanelController) {
        // when panel is full screen, the title of the Navbar is hidden
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

//MARK: - TableView
extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


/*
 (where: {
   Calendar.current.isDate($0.date, inSameDayAs: priorDate)
 })?
 **/
