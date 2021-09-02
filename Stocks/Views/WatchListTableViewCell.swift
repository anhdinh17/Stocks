//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by Anh Dinh on 8/30/21.
//

import UIKit

class WatchListTableViewCell: UITableViewCell {

    static let identifier = "WatchListTableViewCell"
    
    static let preferredHeight: CGFloat = 60
    
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
        label.backgroundColor = .lightGray
        return label
    }()
    
    // Company Label
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.backgroundColor = .gray
        return label
    }()
        
    // Price Label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.backgroundColor = .gray
        return label
    }()
    
    // Change in Price Label
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.backgroundColor = .gray
        return label
    }()
    
    // Instance of StockChartView
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.backgroundColor = .link
        
        return chart
    }()

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
        
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        changeLabel.sizeToFit()
        priceLabel.sizeToFit()
        
        let yStart: CGFloat = (contentView.height - symbolLabel.height - nameLabel.height)/2
        symbolLabel.frame = CGRect(x: separatorInset.left,
                                   y: yStart,
                                   width: symbolLabel.width,
                                   height: symbolLabel.height)
        
        nameLabel.frame = CGRect(x: separatorInset.left,
                                 y: symbolLabel.bottom,
                                 width: nameLabel.width,
                                 height: nameLabel.height)
        
        priceLabel.frame = CGRect(x: contentView.width - 10 - priceLabel.width,
                                  y: 0,
                                  width: priceLabel.width,
                                  height: priceLabel.height)
        
        changeLabel.frame = CGRect(x: contentView.width - 10 - changeLabel.width,
                                   y: priceLabel.bottom,
                                   width: changeLabel.width,
                                   height: changeLabel.height)
        
        miniChartView.frame = CGRect(x: priceLabel.left - (contentView.width/3) - 5,
                                     y: 6,
                                     width: contentView.width/3,
                                     height: contentView.height - 12)
        
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
