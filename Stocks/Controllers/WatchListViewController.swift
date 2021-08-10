//
//  ViewController.swift
//  Stocks
//
//  Created by Anh Dinh on 7/24/21.
//

import UIKit

class WatchListViewController: UIViewController {

//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setUpSearchController()
        
        setUpTitleView()
    }
    
//MARK: - Functions
    private func setUpSearchController(){
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self // set cai nay để xài protocol func
        
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

}

//MARK: - Search Controller
extension WatchListViewController: UISearchResultsUpdating {
    // Every time we hit keyboard, this func updates the contents of the search bar
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              // cast down to SearchResultsVC để xài VC này to display searching results.
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              // trim out all white spaces and the text is not empty
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        // Update results controller
        resultsVC.update(with: ["GOOGL"])
    }
}

//MARK: - Protocol Func from SearchResultsViewController
extension WatchListViewController: SearchResultsViewControllerDelegate {
    
    func searchResultsViewControllerDelegate(searchResult: String) {
        // Present Stock details
    }

}
