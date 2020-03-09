//
//  UITableView+Extension.swift
//  Alamofire
//
//  Created by Vishal on 05/02/19.
//

import UIKit

extension UITableView {
    class func defaultCell(backgroundColor: UIColor = UIColor.clear) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = backgroundColor
        cell.selectionStyle = .none
        return cell
    }
}
