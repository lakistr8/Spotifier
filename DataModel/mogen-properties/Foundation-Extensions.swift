//
//  Foundation-Extensions.swift
//  Spotifier
//
//  Created by Aleksandar Vacić on 13.12.16..
//  Copyright © 2016. iOS Akademija. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static let iso8601Formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:sssZ"		// also test with "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return df
    }()
    
    static let spotifyDayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}
