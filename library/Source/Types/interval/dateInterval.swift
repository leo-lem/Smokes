// Created by Leopold Lemmermann on 29.04.23.

import struct Dependencies.Dependency
import Extensions
import struct Foundation.Calendar
import struct Foundation.Date
import struct Foundation.TimeInterval

public extension Interval {
  var start: Date? {
    @Dependency(\.calendar) var cal

    switch self {
    case .alltime, .to: return nil
    case let .from(date): return date
    case let .fromTo(interval): return interval.start
    case let .day(date), let .week(date), let .month(date), let .year(date):
      return cal.start(of: Subdivision(self)!.comp, for: date)
    }
  }

  var end: Date? {
    @Dependency(\.calendar) var cal

    switch self {
    case .alltime, .from: return nil
    case let .to(date): return date
    case let .fromTo(interval): return interval.end
    case let .day(date), let .week(date), let .month(date), let .year(date):
      return cal.end(of: Subdivision(self)!.comp, for: date)
    }
  }

  var duration: TimeInterval {
    switch self {
    case .alltime, .from, .to: return .infinity
    case .day, .week, .month, .year: return start!.distance(to: end!)
    case let .fromTo(interval): return interval.duration
    }
  }
}
