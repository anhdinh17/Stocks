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
    
//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setUpSearchController()
        
        setUpTitleView()
        
        setUpFoatingPanel()
    }
    
//MARK: - Functions
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
        let vc = NewsViewController(type: .company(symbol: <#T##String#>))
        
        // Create a panel and add it to this VC
        let panel = FloatingPanelController(delegate: self) // syntax này cũng để set this VC là delegate để xài delegate func, ko xài cách này thì set panel.delegate = self cũng giống nhau
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.addPanel(toParent: self)
        panel.set(contentViewController: vc)
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
