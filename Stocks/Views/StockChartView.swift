//
//  StockChartView.swift
//  Stocks
//
//  Created by Anh Dinh on 8/30/21.
//

import UIKit

class StockChartView: UIView {
    
    struct ViewModel {
        let date: [CandleStick]
        let showLegend: Bool
        let showAxis: Bool
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func reset(){
        
    }

}
