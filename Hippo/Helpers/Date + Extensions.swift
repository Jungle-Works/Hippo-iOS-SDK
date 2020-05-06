//
//  Date + Extensions.swift
//  Alamofire
//
//  Created by Intern on 06/05/20.
//

import Foundation
extension Date {

    func findDayDifference(referenceDate: Date) -> Int? {
        let calendar = NSCalendar.current
        let dateOfMsg = calendar.startOfDay(for: self)
        let currentDate = calendar.startOfDay(for: referenceDate)

        let dateDifference: Int? =  calendar.dateComponents([.day], from: dateOfMsg, to: currentDate).day

        return dateDifference
    }

    func formatTo(type: DateFormat) -> String {
        let formatterUTC = DateFormatter()
        formatterUTC.dateFormat = type.rawValue
        formatterUTC.timeZone = TimeZone(secondsFromGMT: 0)
        formatterUTC.locale = Locale(identifier: "en_US_POSIX")

        return formatterUTC.string(from: self)
    }

    func changeDateFormat(toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = toFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.string(from: self)
    }

    func generateFilterUTCDateForServer() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        var dateString = dateFormatter.string(from: self)
        dateString = dateString + "T00:00:00.000Z"

        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var newDate = dateFormatter.date(from: dateString)
        newDate = newDate?.addingTimeInterval(TimeInterval(-CoreUtil.secondsFromGMT))

        return newDate?.toUTCFormatString ?? ""
    }


    func addDay(days: Int) -> Date {
        var currentDate = self
        if days != 0 {
            currentDate = (Calendar.current.date(byAdding: .day, value: days, to: currentDate)) ?? currentDate
        }
        return currentDate
    }
}

public class CoreUtil {
    public static var secondsFromGMT: Int {
        return TimeZone.current.secondsFromGMT()
    }
    public static var minutesFromGMT: Int {
        return (TimeZone.current.secondsFromGMT() / 60)
    }
    public static var offsetFromGMT: Int {
        return Int(TimeZone.current.secondsFromGMT().magnitude)
    }
    
}

