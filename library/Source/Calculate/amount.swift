// Created by Leopold Lemmermann on 29.04.23.

import Extensions
import struct Foundation.Date
import Types

extension Calculate {
  static func amount(interval: Interval, entries: [Date]) -> Int {
    guard entries.count > 0 else { return 0 }

    var endIndex = entries.endIndex, startIndex = entries.startIndex

    if let end = interval.end { endIndex ?= entries.firstIndex { end < $0 } }
    if let start = interval.start { startIndex ?= entries.firstIndex { start <= $0 } ?? entries.endIndex }

    return endIndex - startIndex
  }

  static func amounts(interval: Interval, subdivision: Subdivision, entries: [Date]) -> [Interval: Int]? {
    guard let intervals = interval.enumerate(by: subdivision) else { return nil }

    return Dictionary(uniqueKeysWithValues: intervals.map { ($0, liveValue.amount($0, entries)) })
  }
}
