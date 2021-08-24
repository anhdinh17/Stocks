//
//  Extensions.swift
//  Stocks
//
//  Created by Anh Dinh on 8/9/21.
//

import Foundation
import UIKit

extension String {
    // This func takes in a TimeInterval and returns a String
    // Convert TimeInterval to String, used to convert datetime from JSON (which is TimeInterval) to String(which is the type we want)
    // so this is convert TimeInterval -> Date() -> String
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
}

//MARK: - Dateformatter
extension DateFormatter {
    // Convert DateFormatter to form of "YYYY-MM-dd"
    // this one is to convert Date() to String under the form of "YYYY-MM-dd"
    // this is used in API.shared.news() to calculate time for "from" and "to"
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

//MARK: - Add subviews
extension UIView {
    func addSubviews(_ views: UIView...){
        views.forEach{
            addSubview($0)
        }
    }
}

//MARK: - Framing
extension UIView {
    var width: CGFloat {
        frame.size.width
    }
    
    var height: CGFloat {
        frame.size.height
    }
    
    var left: CGFloat {
        frame.origin.x
    }
    
    var right: CGFloat {
        left + width
    }
    
    var top: CGFloat {
        frame.origin.y
    }
    
    var bottom: CGFloat {
        top + height
    }
}
