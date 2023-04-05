//
//  DateHelper.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 4/5/23.
//

import Foundation

/**
 A class that provides helper methods for working with dates.
 */
class DateHelper {

    /**
     Formats a date string into a more readable format.
     - Parameter string: The date string to be formatted.
     - Returns: A formatted date string or 'nil' if the conversion fails.
     */
    static func formatStringAsDate(_ string: String) -> String? {
        guard let date = postgresTimestampStringToDate(string) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy h:mm a"
        return formatter.string(from: date)
    }

    /**
     Converts a date string from the PostgreSQL format to a Date object.
     - Parameter string: The date string to be converted.
     - Returns: A Date object or 'nil' if the conversion fails.
     */
    static func postgresTimestampStringToDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: string)
    }

}