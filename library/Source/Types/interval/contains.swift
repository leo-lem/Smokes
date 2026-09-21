// Created by Leopold Lemmermann on 29.04.23.

import struct Dependencies.Dependency
import struct Foundation.Date

public extension Interval {
  func contains(_ date: Date) -> Bool {
    if let start, start > date { return false }
    if let end, end < date { return false }
    return true
  }

  func contains(_ interval: Interval) -> Bool {
    switch (start, end, interval.start, interval.end) {
    case (nil, nil, _, _):
      return true
    case let (.some(start1), .some(end1), .some(start2), .some(end2)):
      return start1 <= start2 && end1 >= end2
    case let (.some(start1), nil, .some(start2), _):
      return start1 <= start2
    case let (nil, .some(end1), _, .some(end2)):
      return end1 >= end2
    default:
      return false
    }
  }
}
