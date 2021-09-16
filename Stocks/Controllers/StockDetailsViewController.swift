//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Anh Dinh on 7/24/21.
//

import SafariServices
import UIKit

class StockDetailsViewController: UIViewController {
    
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
        
        setUpTable()
        
        fetchFinancialData()
        
        fetchNews()
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
    }
    
    private func fetchFinancialData(){
        renderChart()
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
                    self?.table.reloadData()
                }
            case .failure(let errror):
                print(errror)
            }
        }
    }
    
    private func renderChart(){
        
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
