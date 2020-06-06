//
//  Date + Custom.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 05.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation

extension Date {
     func asString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm "
        return dateFormatter.string(from: self)
    }
}
