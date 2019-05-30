//
//  DateExtension.swift
//  OVOIOSCodingChallenge
//
//  Created by Klemen Košir on 29/05/2019.
//  Copyright © 2019 Our Very Own Pty Ltd. All rights reserved.
//

import Foundation

extension Date {
    /// Date helper function for parsing from string
    ///
    /// - Parameter string: Any valid date string
    init?(from string: String) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        // we trim the date string to length 19 because we dont need miliseconds in this case
        guard let date = df.date(from: String(string.prefix(19))) else {
            return nil
        }
        self = date
    }
    
    /// Date helper function for parsing date to string with custom format
    ///
    /// - Parameter format: String date format how we want the date to be formatted
    func toString(format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
    
}
