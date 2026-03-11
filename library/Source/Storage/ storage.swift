// Created by Leopold Lemmermann on 11.03.26.

import Dependencies
import Foundation
import Types

#if canImport(WidgetKit)
import WidgetKit
#endif

public struct Storage: Sendable {
  public var loadEntries: @Sendable () throws -> Dates
  public var saveEntries: @Sendable (Dates) throws -> Void

  public var loadAmountOption: @Sendable () -> AmountOption
  public var saveAmountOption: @Sendable (AmountOption) -> Void

  public var loadTimeOption: @Sendable () -> TimeOption
  public var saveTimeOption: @Sendable (TimeOption) -> Void

  public var addEntry: @Sendable (Date) throws -> Dates
  public var removeNearestEntry: @Sendable (Date) throws -> Dates
}

public extension DependencyValues {
  var storage: Storage {
    get { self[Storage.self] }
    set { self[Storage.self] = newValue }
  }
}

extension Storage: DependencyKey {
  public static let liveValue = Self(
    loadEntries: {
      try EntryStore.load()
    },
    saveEntries: { entries in
      try EntryStore.save(entries)
      reloadWidgets()
    },
    loadAmountOption: {
      DashboardPreferences.amountOption
    },
    saveAmountOption: { option in
      DashboardPreferences.amountOption = option
      reloadWidgets()
    },
    loadTimeOption: {
      DashboardPreferences.timeOption
    },
    saveTimeOption: { option in
      DashboardPreferences.timeOption = option
      reloadWidgets()
    },
    addEntry: { date in
      let entries = try EntryStore.add(date)
      reloadWidgets()
      return entries
    },
    removeNearestEntry: { date in
      let entries = try EntryStore.removeNearest(to: date)
      reloadWidgets()
      return entries
    }
  )

#if DEBUG
  public static let previewValue = Storage(
    loadEntries: { Dates()},
    saveEntries: { _ in },
    loadAmountOption: { .month },
    saveAmountOption: { _ in },
    loadTimeOption: { .longestBreak },
    saveTimeOption: { _ in },
    addEntry: { Dates([$0]) },
    removeNearestEntry: { _ in Dates() }
  )
#endif
}

private func reloadWidgets() {
#if canImport(WidgetKit)
  WidgetCenter.shared.reloadAllTimelines()
#endif
}
