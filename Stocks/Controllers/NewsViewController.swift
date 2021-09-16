//
//  TopStoriesViewController.swift
//  Stocks
//
//  Created by Anh Dinh on 7/24/21.
//

import SafariServices
import UIKit

class NewsViewController: UIViewController {

    public var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        
        // Register header
        table.register(NewsHeaderView.self,
                       forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        
        // Register cell
        table.register(NewsStoryTableViewCell.self,
                       forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        
        return table
    }()
 
    // Array of stories
    private var stories = [NewsStory]()
    
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
        APICaller.shared.news(for: type) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    // set "stories" of this class = stories received from the call.
                    // Which is an array of [NewsStory]
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func open(url: URL){
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
}

//MARK: - TableView Protocol
extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    // Custom Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        
        /*
        .init is short form of NewsStoryTableViewCell.ViewModel()
        each item is an object of NewsStory
        */
        cell.configure(with: .init(model: stories[indexPath.row]))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    // Select 1 cell and go to the page of the news using SafariServices.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // get 1 object of stories array, which is a NewsStory object
        let story = stories[indexPath.row]
        
        // convert url String to URL
        guard let url = URL(string:story.url) else {
            presentFailedToOpenAlert()
            return
        }
        
        // Open the page of the news
        open(url: url)
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
    
    private func presentFailedToOpenAlert(){
        let alert = UIAlertController(title: "Failed to Open Page",
                                      message: "Cannot Open the page",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
    }
    
}
