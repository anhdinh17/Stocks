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
    
    static var maxChangeWidth: CGFloat = 0
    
    // TableView
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self,
                       forCellReuseIdentifier: WatchListTableViewCell.identifier)
        return table
    }()
    
    // ????? Model
    private var watchlistMap: [String : [CandleStick]] = [:]
    
    // ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    // Observer
    private var observer: NSObjectProtocol?
    
//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .systemBackground
        
        setUpSearchController()
        
        setUpTitleView()
        
        setUpTableView()
        
        fetchWatchlistData()
        
        setUpFoatingPanel()
        
        setUpObserver()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
//MARK: - Functions
    
    private func fetchWatchlistData(){
        // "symbols" is an array of companies' symbols
        // ["FB", "GOOG", "PINS", "AAPL", "MSFT", "AMZN", "WORK", "NVDA", "NKE", "SNAP"]
        var symbols = PersistenceManager.share.watchList
        symbols = symbols.filter({$0 != "WORK"})
        
        print("Symbols:\(symbols)")
        
        let group = DispatchGroup()
        
        // API call for symbols which don't have data yet.
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            
            // Get market data for each symbol
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
                    
                    // M??nh mu???n 1 symbol ???ng v???i 1 array c???a [CandleSticks]
                    // hay c?? ngh??a l?? 1 symbol ???ng v???i 1 data market c???a n??
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
                                    // s??? d???ng extension ????? chuy???n 1 Double th??nh 1 String v???i 2 ch??? s??? d?????i d???ng percentage
                                    changePercentage: String.percentage(from: changePercentage),
                                    chartViewModel: .init(data: candleSticks.reversed().map{$0.close},
                                                          showLegend: false,
                                                          showAxis: false,
                                                          fillColor: changePercentage < 0 ? .systemRed : .systemGreen))
            )
        }
        
//        var test = watchlistMap["AAPL"]
//        test?.reversed().map{$0.close}
//        print("This is test: \(test)")
        
        self.viewModels = viewModels
    }
    
    // get the difference between prior and current closing price.
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        
        //print("This is data.first: \(data.first)")
        
        // latest closing price and prior closing price, data from candleSticks
        guard let latestClose = data.first?.close,
              // ch??a hi???u kh??c n??y: T???i sao l?? data.first ????? l???y prior?
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
        
        return String.formatted(number: closingPrice)
    }
    
    private func setUpObserver(){
        // wait for notification of ".didAddToWatchList", then execute closure.
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList,
                                                          object: nil,
                                                          queue: .main, using: { [weak self]_ in
                                                            self?.viewModels.removeAll()
                                                            self?.fetchWatchlistData()
                                                          })
    }
    
    private func setUpTableView(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpSearchController(){
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self // set cai nay ????? x??i delegate func c???a SearchResultViewController
        
        let searchVC = UISearchController(searchResultsController: resultVC)
        // this one is for the protocol UISearchResultsUpdating
        searchVC.searchResultsUpdater = self
        
        // add search bar to Nav Bar
        navigationItem.searchController = searchVC
    }
    
    private func setUpTitleView(){
        // T???o 1 UIView ????? add v?? VC n??y
        // C??ch t???o UIView c?? s???n frame
        let titleView = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: view.width,
                                             height: navigationController?.navigationBar.height ?? 100))
        
        // D??ng n??y nh?? l?? add titleView v?? Navigation Bar, gi???ng nh?? addSubView, ko c?? d??ng n??y th?? titleView ko hi???n l??n nav Bar
        navigationItem.titleView = titleView
        
        // T???o 1 label ????? add v?? UIView n??y
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
        let panel = FloatingPanelController(delegate: self) // syntax n??y c??ng ????? set this VC l?? delegate ????? x??i delegate func, ko x??i c??ch n??y th?? set panel.delegate = self c??ng gi???ng nhau
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
              // cast down to SearchResultsVC ????? x??i VC n??y to display searching results.
              // d??ng n??y l?? 1 trong nh???ng b?????c c???a process t???o search bar.
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              // trim out all white spaces and the text is not empty
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        /*
        The whole timer thing means: everytime user hit a key on keyboard, it resets the timer then kick off new timer to search for API.
         Khi user b???m 1 ph??m tr??n keyboard, 0.3 gi??y sau API call s??? ch???y, v???y n???u kho???ng th???i gian gi???a m???i l???n b???m t??? 0.3 tr??? xu???ng th?? API call s??? kh??ng ch???y. V???y s??? gi??p l??m gi???m s??? l???n g???i API
        */
        
        // Reset timer
        searchTimer?.invalidate()
        
        // Kick off new timer
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            // Call API to search
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response): // response l?? 1 SearchResponse Object
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
    // func n??y l?? khi m??nh search v?? click v??o 1 result tr??n table c???a search
    // go to StockDetailsVC
    func searchResultsViewControllerDelegate(searchResult: SearchResult) {
        // Resign keyboard:
        // because search bar is in navigation bar, so we use this syntax
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        // Present Stock details
        /* C??ch 1:
         let vc = StockDetailsViewController()
         vc.title = searchResult.description
         navigationController?.pushViewController(vc, animated: true)
        */
       
        // C??ch 2:
        let vc = StockDetailsViewController(symbol: searchResult.displaySymbol,
                                            companyName: searchResult.description)
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
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        
        cell.delegate = self
        
        cell.configure(with: viewModels[indexPath.row])
        
        return cell
    }
    
    // Height for cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    // Select a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the instance from the cell row
        // viewModel is 1 instance of WatchListTableViewCell.ViewModel
        let viewModel = viewModels[indexPath.row]
    
        // go to StockDetailsVC when clicking on a cell
        let vc = StockDetailsViewController(symbol: viewModel.symbol,
                                            companyName: viewModel.companyName,
                                            candleStickData: watchlistMap[viewModel.symbol] ?? [])
        vc.title = "Stock Details"
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
    }
    
    // Swipe to delete cell: 3 func
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            // Update Persistence
            PersistenceManager.share.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
            
            // Update viewModels array
            viewModels.remove(at: indexPath.row)
            
            // Delete Row
            tableView.deleteRows(at: [indexPath], with: .automatic)

            tableView.endUpdates()
        }
    }
}


/*
 (where: {
   Calendar.current.isDate($0.date, inSameDayAs: priorDate)
 })?
 **/

//MARK: - Delegate for WatchListTableViewCell
extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdateMaxWidth() {
        tableView.reloadData()
    }
}
