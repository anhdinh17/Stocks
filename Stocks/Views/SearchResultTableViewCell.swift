//
//  SearchResultTableViewCell.swift
//  Stocks
//
//  Created by Anh Dinh on 8/9/21.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        /* the .subtitile is for the style that has one label on left top corner and 1 sub label below it 
        */
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
