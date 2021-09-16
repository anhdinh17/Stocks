//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Anh Dinh on 7/24/21.
//

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
        table.register(NewsStoryTableViewCell.self, forHeaderFooterViewReuseIdentifier: NewsStoryTableViewCell.identifier)
        
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
    
    private func fetchNews(){
        
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
                                     shouldShowAddButton: true))
        
        return header
    }
    
    // Header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    // select a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: - Header
extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        // Add to WatchList
    }
    
    
}
