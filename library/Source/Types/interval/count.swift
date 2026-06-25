// Created by Leopold Lemmermann on 02.04.23.

import struct Dependencies.Dependency
import struct Foundation.Calendar
import struct Foundation.Date

public extension Interval {
  var isCountable: Bool {
    switch self {
    case .alltime, .from, .to: return false
    case .day, .week, .month, .year, .fromTo: return true
    }
  }

  func count(by subdivision: Subdivision) -> Int? {
    @Dependency(\.calendar) var cal

    guard let start, let end else { return .max }

    return cal.dateComponents([subdivision.comp], from: start, to: end).value(for: subdivision.comp)
  }
}
