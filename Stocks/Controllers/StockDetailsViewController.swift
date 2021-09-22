//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Anh Dinh on 7/24/21.
//

import SafariServices
import UIKit

class StockDetailsViewController: UIViewController {

//MARK: - Properties
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick] = []
    
    private let table: UITableView = {
        let table = UITableView()
        
        // register Header
        table.register(NewsHeaderView.self,
                       forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        
        // register custom cell
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        
        return table
    }()
    
    private var stories = [NewsStory]()

    private var metrics: Metrics?
    
//MARK: - Init
    init(symbol: String,
         companyName: String,
         // By default, this is an empty array
         candleStickData: [CandleStick] = []){
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        title = companyName
        
        setUpTable()
        
        fetchFinancialData()
        
        fetchNews()
        
        setUpCloseButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        table.frame = view.bounds
    }
    
//MARK: - Funcs
    private func setUpTable(){
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        
        // create a view above table above table content, it's above Header of the tableView.
        table.tableHeaderView = UIView(frame: CGRect(x: 0,
                                                     y: 0,
                                                     width: view.width,
                                                     height: (view.width * 0.7) + 100))
    }
    
    // Get metric data
    private func fetchFinancialData(){
        let group = DispatchGroup()
        
        // fetch candle sticks if needed
        if candleStickData.isEmpty{
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        // get metrics for specific symbol to display it in the chart area
        group.enter()
        APICaller.shared.financialmetrics(for: symbol) { [weak self] result in
            defer{
                group.leave()
            }
            
            switch result {
            // response is 1 instance of object FinancialMetricsResponse
            case .success(let response):
                let metrics = response.metric
                // let this class "metrics" = this metrics above
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main) {[weak self] in
            self?.renderChart()
        }

    }
    
    // get news for company symbol
    private func fetchNews(){
        // dùng .company(symbol: symbol) vì mình muốn get the news for this specific company
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    // set this class stories = stories from closure
                    self?.stories = stories
                    // reload tableView to display UI with "stories" array
                    self?.table.reloadData()
                }
            case .failure(let errror):
                print(errror)
            }
        }
    }
    
    // header, where the chart is
    private func renderChart(){
        // Add StockDetailHeaderView to this ViewController, StockDetailHeaderView is an UIView.
        // set the frame to be the same as table.tableHeaderView
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: view.width,
                                                             height: (view.width * 0.7) + 100))
        
        // create an empty array of MetricCollectionViewCell.ViewModel
        // why we have to do this? Vì theo công thức, muốn chạy collectionView Cell thì phải có array của MetricCollectionViewCell.ViewModel, có array này rồi thì collectionView.reloadData() sẽ chạy đươc UI của từng cell
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        
        // lấy data từ metrics
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52W Low", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol", value: "\(metrics.TenDayAverageTradingVolume)"))
        }
        
        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        
        // configure to reload collectionView with an array of viewModels above
        headerView.configure(chartViewModel: .init(data: candleStickData.reversed().map{$0.close},
                                                   showLegend: true,
                                                   showAxis: true,
                                                   fillColor: change < 0 ? .systemRed : .systemGreen),
                             metricViewModels: viewModels)
        
        // let tableHeaderView = thằng headerView này
        table.tableHeaderView = headerView
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        
        //print("This is data.first: \(data.first)")
        
        // latest closing price and prior closing price, data from candleSticks
        guard let latestClose = data.first?.close,
              // chưa hiểu khúc này: Tại sao là data.first để lấy prior?
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
    
    // close button on top right
    private func setUpCloseButton(){
        // add a close button to nav bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    @objc private func didTapClose(){
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - TableView
extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier,
                                                       for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        
        // Mỗi indexPath.row là 1 instance của "NewStory"
        cell.configure(with: .init(model: stories[indexPath.row]))
        
        return cell
    }
    
    // Cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        
        header.delegate = self
        header.configure(with: .init(title: symbol.uppercased(),
                                     // if watchlist contains this symbol, we hide the add button
                                     shouldShowAddButton: !PersistenceManager.share.watchlistContains(symbol: symbol)))
        
        return header
    }
    
    // Header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    // select a cell to go to the page of the news
    // Using SafariServices
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

//MARK: - Header
extension StockDetailsViewController: NewsHeaderViewDelegate {
    
    // this delegate func: when users click on add button, this adds the symbol to watchlist and hide the button
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        // hide button
        headerView.button.isHidden = true
        
        // add to watchlist
        PersistenceManager.share.addToWatchlist(symbol: symbol,
                                                companyName: companyName)
        
        // alert to inform that symbol added to watchlist
        let alert = UIAlertController(title: "Added to Wathclist",
                                      message: "\(companyName) has been added to your watchlist",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
