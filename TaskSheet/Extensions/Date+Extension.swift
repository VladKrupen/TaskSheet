//
//  Date+Extension.swift
//  TaskSheet
//
//  Created by Vlad on 17.11.24.
//

import Foundation

extension Date {
    func toCustomFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.string(from: self)
    }
}
