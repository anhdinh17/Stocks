//
//  MetricCollectionViewCell.swift
//  Stocks
//
//  Created by Anh Dinh on 9/20/21.
//

import UIKit

class MetricCollectionViewCell: UICollectionViewCell {
    static let identifier = "MetricCollectionViewCell"
    
    struct ViewModel {
        let name: String
        let value: String
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        return label
    }()
    
//MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // add subviews
        contentView.clipsToBounds = true
        contentView.addSubviews(nameLabel,valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.sizeToFit()
        valueLabel.sizeToFit()
        
        nameLabel.frame = CGRect(x: 3,
                                 y: 0,
                                 width: nameLabel.width,
                                 height: contentView.height)
        valueLabel.frame = CGRect(x: nameLabel.right + 3,
                                  y: 0,
                                  width: valueLabel.width,
                                  height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        valueLabel.text = nil
    }

//MARK: - Function
    public func configure(with viewModel: ViewModel){
        nameLabel.text = viewModel.name
        valueLabel.text = viewModel.value
    }
    
}
