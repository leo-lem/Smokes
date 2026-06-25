// Created by Leopold Lemmermann on 29.04.23.

import struct Dependencies.Dependency
import struct Foundation.Calendar
import struct Foundation.Date

public extension Interval {
  func next(in bounds: Interval? = nil) -> Self? {
    @Dependency(\.calendar) var cal

    if let end, let bound = bounds?.end, bound <= end { return nil }

    switch self {
    case let .day(date):
      return .day(cal.date(byAdding: Subdivision(self)!.comp, value: 1, to: date)!)
    case let .week(date):
      return .week(cal.date(byAdding: Subdivision(self)!.comp, value: 1, to: date)!)
    case let .month(date):
      return .month(cal.date(byAdding: Subdivision(self)!.comp, value: 1, to: date)!)
    case let .year(date):
      return .year(cal.date(byAdding: Subdivision(self)!.comp, value: 1, to: date)!)
    default:
      return nil
    }
  }

  func previous(in bounds: Interval? = nil) -> Self? {
    @Dependency(\.calendar) var cal

    if let start, let bound = bounds?.start, start <= bound { return nil }

    switch self {
    case let .day(date):
      return .day(cal.date(byAdding: Subdivision(self)!.comp, value: -1, to: date)!)
    case let .week(date):
      return .week(cal.date(byAdding: Subdivision(self)!.comp, value: -1, to: date)!)
    case let .month(date):
      return .month(cal.date(byAdding: Subdivision(self)!.comp, value: -1, to: date)!)
    case let .year(date):
      return .year(cal.date(byAdding: Subdivision(self)!.comp, value: -1, to: date)!)
    default:
      return nil
    }
  }
}
