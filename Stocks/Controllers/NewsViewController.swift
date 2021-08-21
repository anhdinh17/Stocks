//
//  TopStoriesViewController.swift
//  Stocks
//
//  Created by Anh Dinh on 7/24/21.
//

import UIKit

class NewsViewController: UIViewController {

    public var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        
        // Register header
        table.register(NewsHeaderView.self,
                       forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        
        return table
    }()
 
    // Array of stories
    private var stories = [String]()
    
    private var type: Type
    
    // syntax to call a var that is same name as Swift keyword
    enum `Type` {
        case topStories
        case company(symbol: String)
        
        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    init(type: Type){
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTable()
        
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }

//MARK: - Functions
    private func setUpTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func fetchNews(){
        
    }
    
    private func open(url: URL){
        
    }
    
}

//MARK: - TableView Protocol
extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    // cast the header to NewsHeaderView file
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        
        /*
        .init is short form of NewsHeaderView.ViewModel(title: , shouldShowAddButton: )
        */
        header.configure(with: .init(title: self.type.title,
                                     shouldShowAddButton: false))
        
        return header
    }
    
}
