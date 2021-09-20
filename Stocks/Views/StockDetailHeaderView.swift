//
//  StockDetailHeaderView.swift
//  Stocks
//
//  Created by Anh Dinh on 9/17/21.
//

import UIKit

class StockDetailHeaderView: UIView {

    // array of viewModel of MetricCollectionViewCell
    // xài theo công thức tạo table/cell
    private var metricViewModels = [MetricCollectionViewCell.ViewModel]()
    
    // Subviews
    
    // ChartView
    private let chartView = StockChartView()
    
    // CollectionView
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        // Register custom cell
        collectionView.register(MetricCollectionViewCell.self,
                                forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        
        // add subviews
        addSubviews(chartView,collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        chartView.frame = CGRect(x: 0, y: 0, width: width, height: height - 100)
        collectionView.frame = CGRect(x: 0, y: height - 100, width: width, height: 100)
    }
    
//MARK: - Funcs
    public func configure(chartViewModel: StockChartView.ViewModel,
                          metricViewModels: [MetricCollectionViewCell.ViewModel]){
        // Update Chart
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }
    
}

//MARK: - CollectionView
extension StockDetailHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
        
        // viewModel is 1 instance of MetricCollectionViewCell.ViewModel
        let viewModel = metricViewModels[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricCollectionViewCell.identifier,
                                                            for: indexPath) as? MetricCollectionViewCell else {
            fatalError()
        }
        
        cell.configure(with: viewModel)
        
        return cell
    }
    
    // size of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: height/3)
    }
}
