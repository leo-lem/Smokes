// Created by Leopold Lemmermann on 02.02.25.

import struct Dependencies.Dependency
import Foundation

public struct Dates: Equatable, Codable, Sendable {
  public internal(set) var array: ArrayType

  public init(_ entries: ArrayType) { self.array = entries }

  public var startDate: Date {
    @Dependency(\.calendar) var cal
    @Dependency(\.date.now) var now
    return cal.startOfDay(for: array.first ?? now)
  }

  public var endDate: Date {
    @Dependency(\.calendar) var cal
    @Dependency(\.date.now) var now
    return cal.endOfDay(for: now)
  }

  public var bounds: Interval { Interval.fromTo(.init(start: startDate, end: endDate)) }

  public func clamp(_ interval: Interval) -> Interval {
    if bounds.contains(interval) { return interval }

    let start = Swift.max(startDate, interval.start ?? startDate)
    let end = Swift.min(endDate, interval.end ?? endDate)

    guard start <= end else { return .fromTo(.init()) }

    return .fromTo(.init(start: start, end: end))
  }
}

extension Dates: RangeReplaceableCollection, ExpressibleByArrayLiteral {
  public typealias ArrayType = [Date]
  public typealias Index = ArrayType.Index
  public typealias Element = ArrayType.Element

  public var startIndex: Index { array.startIndex }
  public var endIndex: Index { array.endIndex }

  public init() { array = [] }

  public init(arrayLiteral elements: Element...) { array = elements }

  public subscript(index: Index) -> Element { array[index] }

  public func index(after index: Index) -> Index { array.index(after: index) }

  public mutating func replaceSubrange<C: Collection>(
    _ subrange: Range<ArrayType.Index>, with newElements: C
  ) where ArrayType.Element == C.Element {
    array.replaceSubrange(subrange, with: newElements)
  }
}
