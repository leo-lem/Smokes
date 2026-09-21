// Created by Leopold Lemmermann on 01.04.23.

import struct Dependencies.Dependency
import SwiftUI

public enum AmountOption: String, CaseIterable, Sendable {
  case yesterday
  case week
  case month
  case year

  public var label: String {
    switch self {
    case .yesterday: String(localized: .yesterday)
    case .week: String(localized: .week)
    case .month: String(localized: .month)
    case .year: String(localized: .year)
    }
  }

  public var interval: Interval {
    @Dependency(\.calendar) var cal
    @Dependency(\.date.now) var now

    switch self {
    case .yesterday: return .day(cal.startOfDay(for: now) - 1)
    case .week: return .week(now)
    case .month: return .month(now)
    case .year: return .year(now)
    }
  }
}

public enum TimeOption: String, CaseIterable, Sendable {
  case sinceLast
  case longestBreak

  public var label: String {
    switch self {
    case .sinceLast: String(localized: .sinceLast)
    case .longestBreak: String(localized: .longestBreak)
    }
  }
}
