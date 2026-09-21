// Created by Leopold Lemmermann on 02.04.23.

import struct Dependencies.Dependency
import struct Foundation.Calendar
import struct Foundation.Date

public extension Interval {
  func enumerate(by subdivision: Subdivision, in bounds: Interval? = nil) -> [Interval]? {
    @Dependency(\.calendar) var cal

    guard var start, var end else { return nil }
    start = max(start, bounds?.start ?? start)
    end = min(end, bounds?.end ?? end)

    var intervals = [Interval](), date = start

    while date < end {
      intervals.append(subdivision.interval(date))
      date = cal.date(byAdding: subdivision.comp, value: 1, to: date)!
    }

    if cal.isDate(date, equalTo: end, toGranularity: subdivision.comp) {
      intervals.append(subdivision.interval(date))
    }

    return intervals
  }
}
