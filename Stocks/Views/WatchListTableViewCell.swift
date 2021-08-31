//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by Anh Dinh on 8/30/21.
//

import UIKit

class WatchListTableViewCell: UITableViewCell {

    static let identifier = "WatchListTableViewCell"
    
    static let preferredHeight: CGFloat = 14
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String // fromatted
        let changeColor: UIColor
        let changePercentage: String // formatted
        // let chartViewModel: StockChartView.ViewModel
    }
    
    // Symbol Label
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    // Company Label
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
        
    // Price Label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    // Change in Price Label
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    // Instance of StockChartView
    private let miniChartView = StockChartView()

//MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews(symbolLabel,
                    nameLabel,
                    miniChartView,
                    priceLabel,
                    changeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel){
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        
        // Configure chart
    }
}
