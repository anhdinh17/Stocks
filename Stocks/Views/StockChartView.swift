//
//  StockChartView.swift
//  Stocks
//
//  Created by Anh Dinh on 8/30/21.
//

import Charts
import UIKit

class StockChartView: UIView {
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
        let fillColor: UIColor
    }

    // Chart
    private let chartView: LineChartView = {
        let chartView = LineChartView()
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(true)
        chartView.xAxis.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        
        return chartView
    }()
    
//MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // add chart
        addSubview(chartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // position of chartView
        chartView.frame = bounds
    }

//MARK: - Functions
    func reset(){
        chartView.data = nil
    }
    
    func configure(with viewModel: ViewModel){
        var entries = [ChartDataEntry]()
        
        for (index, value) in viewModel.data.enumerated(){
            entries.append(
                .init(x: Double(index),
                      y: value)
            )
        }
        
        chartView.rightAxis.enabled = viewModel.showAxis
        chartView.legend.enabled = viewModel.showLegend
        
        let dataSet = LineChartDataSet(entries: entries, label: "7 Days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.drawFilledEnabled = true
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        
        let data = LineChartData(dataSet: dataSet)
        
        chartView.data = data
    }

}
