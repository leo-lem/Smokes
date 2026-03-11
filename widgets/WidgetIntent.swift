// Created by Leopold Lemmermann on 11.03.26.

import AppIntents
import Calculate
import Dependencies
import Types

enum WidgetAmountOption: String, CaseIterable, AppEnum {
  case today
  case yesterday
  case week
  case month
  case year
  case alltime

  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Count")
  static let caseDisplayRepresentations: [WidgetAmountOption: DisplayRepresentation] = [
    .today: "Today",
    .yesterday: "Yesterday",
    .week: "This Week",
    .month: "This Month",
    .year: "This Year",
    .alltime: "All Time"
  ]

  var label: String {
    switch self {
    case .today: String(localized: .today)
    case .yesterday: String(localized: .yesterday)
    case .week: String(localized: .week)
    case .month: String(localized: .month)
    case .year: String(localized: .year)
    case .alltime: String(localized: .alltime)
    }
  }

  var interval: Interval {
    switch self {
    case .today: .day(.now)
    case .yesterday: AmountOption.yesterday.interval
    case .week: AmountOption.week.interval
    case .month: AmountOption.month.interval
    case .year: AmountOption.year.interval
    case .alltime: .alltime
    }
  }

  func amount(in entries: Dates) -> Int {
    @Dependency(\.calculate.amount) var amount
    return amount(interval, entries.array)
  }
}

enum WidgetTimeOption: String, CaseIterable, AppEnum {
  case sinceLast
  case longestBreak

  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Time")
  static let caseDisplayRepresentations: [WidgetTimeOption: DisplayRepresentation] = [
    .sinceLast: "since last",
    .longestBreak: "longest break"
  ]

  var label: String {
    switch self {
    case .sinceLast: String(localized: .sinceLast)
    case .longestBreak: String(localized: .longestBreak)
    }
  }

  func time(at date: Date, in entries: Dates) -> TimeInterval {
    @Dependency(\.calculate) var calculate

    return switch self {
    case .sinceLast:
      calculate.break(date, entries.array)
    case .longestBreak:
      calculate.longestBreak(date, entries.array)
    }
  }
}

struct SmokesWidgetIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Smokes"
  static let description = IntentDescription("Show your current smoke count and add new smokes")

  @Parameter(title: "Count") var widgetAmountOption: WidgetAmountOption?
  @Parameter(title: "Time") var widgetTimeOption: WidgetTimeOption?

  init() {
    self.widgetAmountOption = .week
    self.widgetTimeOption = .sinceLast
  }
}

extension SmokesWidgetIntent {
  var amountOption: WidgetAmountOption {
    widgetAmountOption ?? .week
  }

  var timeOption: WidgetTimeOption {
    widgetTimeOption ?? .sinceLast
  }
}
