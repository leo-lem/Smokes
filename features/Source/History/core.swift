// Created by Leopold Lemmermann on 04.02.25.

import Calculate
import ComposableArchitecture
import Extensions
import Foundation
import Storage
import Types

@Reducer public struct History {
  @ObservableState public struct State: Equatable {
    @Shared var entries: Dates
    @Shared var option: HistoryOption

    var selection: Date
    var editing: Bool

    public init(
      entries: Dates = Dates(),
      option: HistoryOption = .week,
      selection: Date = Dependency(\.date.now).wrappedValue - 86400,
      editing: Bool = false
    ) {
      _entries = Shared(wrappedValue: entries, .fileStorage(AppGroup.containerURL.appending(path: "entries.json")))
      _option = Shared(wrappedValue: option, .appStorage("history_option"))
      self.selection = selection
      self.editing = editing
    }
  }
  
  public enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case addButtonTapped
    case removeButtonTapped
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .addButtonTapped:
        state.$entries.withLock {
          $0.insert(state.selection, at: state.entries.firstIndex { state.selection < $0 } ?? state.entries.endIndex)
        }

      case .removeButtonTapped:
        if
          let nearest = state.entries
            .min(by: { abs($0.distance(to: state.selection)) < abs($1.distance(to: state.selection)) }),
          cal.isDate(nearest, inSameDayAs: state.selection) {
            state.$entries.withLock {
              _ = $0.remove(at: state.entries.firstIndex(of: nearest)!)
            }
        }

      case .binding: break
      }

      return .none
    }
  }

  @Dependency(\.calendar) var cal

  public init() {}
}

public extension History.State {
  var interval: Interval { option.interval(selection) }
  var subdivision: Subdivision { option.subdivision }

  var bounds: Interval {
    @Dependency(\.calendar) var cal
    @Dependency(\.date.now) var now
    return Interval.to(cal.endOfDay(for: now))
  }

  var dayAmount: Int {
    @Dependency(\.calculate.amount) var amount
    return amount(.day(selection), entries.array)
  }
  var untilHereAmount: Int? {
    @Dependency(\.calculate.amount) var amount
    @Dependency(\.calendar) var cal
    return amount(.to(cal.endOfDay(for: selection)), entries.array)
  }
  var optionAmount: Int {
    @Dependency(\.calculate.amount) var amount
    return amount(interval, entries.array)
  }
  var plotData: [Interval: Int]? {
    @Dependency(\.calculate.amounts) var amounts
    return amounts(interval, subdivision, entries.array)
  }
}
