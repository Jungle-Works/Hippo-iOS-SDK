//
//  FilterInfo.swift
//  Hippo
//
//  Created by soc-admin on 20/05/22.
//

import Foundation


class DateFilterInfo {
    var name: String
    var description: String
    
    var startDate: Date?
    var startDateString: String?
    
    var endDate: Date?
    var endDateString: String?
    
    var isSelected: Bool = false
    var id: String
    var isCustomDate: Bool = false
    
    init(name: String, description: String) {
        self.id = UUID().uuidString
        self.name = name
        self.description = description
    }
    
    func getStartDateString() -> String? {
        if isCustomDate {
            return startDate?.toUTCFormatString
        } else {
            return startDate?.generateFilterUTCDateForServer()
        }
    }
    func getEndDateString() -> String? {
        if isCustomDate {
            return endDate?.toUTCFormatString
        } else {
            return endDate?.generateFilterUTCDateForServer()
        }
    }
    func clone() -> DateFilterInfo {
        
        let newObject = DateFilterInfo(name: name, description: description)
        newObject.id = id
        newObject.isSelected = isSelected
        newObject.endDate = endDate
        newObject.endDateString = endDateString
        newObject.isCustomDate = isCustomDate
        newObject.startDate = startDate
        newObject.startDateString = startDateString
        
        return newObject
    }
    
    static func cloneArray(list: [DateFilterInfo]) -> [DateFilterInfo] {
        var clonedList: [DateFilterInfo] = []
        
        for each in list {
           clonedList.append(each.clone())
        }
        return clonedList
    }
    
    static func initalDate() -> [DateFilterInfo] {
        var list: [DateFilterInfo] = []
        let currentDate = Date()
        let currentTime = currentDate
        let previousDay = currentDate.addDay(days: -1)
        let dateOfLast7Day = currentDate.addDay(days: -6)
        let dateOfLast30Day = currentDate.addDay(days: -29)
        
        
        let currentDateInfo = DateFilterInfo(name: "Today", description: currentTime.changeDateFormat(toFormat: "MMM d"))
        currentDateInfo.startDate = currentDate
        
        let previousDateInfo = DateFilterInfo(name: "Yesterday", description: previousDay.changeDateFormat(toFormat: "MMM d"))
        previousDateInfo.startDate = previousDay
        previousDateInfo.endDate = currentDate
        
        let last7DaysDescription = dateOfLast7Day.changeDateFormat(toFormat: "MMM d") + " - " + currentDate.changeDateFormat(toFormat: "MMM d")
        let dateOfLastDayInfo = DateFilterInfo(name: "Last 7 days", description: last7DaysDescription)
        dateOfLastDayInfo.startDate = dateOfLast7Day
        
        let last30DaysDescription = dateOfLast30Day.changeDateFormat(toFormat: "MMM d") + " - " + currentDate.changeDateFormat(toFormat: "MMM d")
        let last30DaysInfo = DateFilterInfo(name: "Last 30 days", description: last30DaysDescription)
        last30DaysInfo.startDate = dateOfLast30Day

        let customDaysInfo = DateFilterInfo(name: "Custom Range", description: "Select custom date range")
        customDaysInfo.isCustomDate = true
        customDaysInfo.endDate = currentDate
        customDaysInfo.startDate = dateOfLast7Day
        
        list.append(currentDateInfo)
        list.append(previousDateInfo)
        list.append(dateOfLastDayInfo)
        list.append(last30DaysInfo)
        list.append(customDaysInfo)
        
        return list
    }
}


