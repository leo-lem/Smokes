// Created by Leopold Lemmermann on 02.02.25.

import Calculate
import ComposableArchitecture
import Extensions
import Foundation
import Storage
import Types

@Reducer public struct Dashboard: Sendable {
  @ObservableState public struct State: Equatable {
    @Shared var entries: Dates
    @Shared var amountOption: AmountOption
    @Shared var timeOption: TimeOption

    var now: Date

    public init(
      entries: Dates = Dates(),
      amountOption: AmountOption = .week,
      timeOption: TimeOption = .sinceLast,
      now: Date = Dependency(\.date.now).wrappedValue
    ) {
      _entries = Shared(wrappedValue: entries, .fileStorage(AppGroup.containerURL.appending(path: "entries.json")))
      _amountOption = Shared(wrappedValue: amountOption, .appStorage("dashboard_amountOption"))
      _timeOption = Shared(wrappedValue: timeOption, .appStorage("dashboard_timeOption"))
      self.now = now
    }
  }

  public enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case reload
    case addButtonTapped
    case removeButtonTapped
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .reload:
        state.now = now
        return .run { send in
          try? await clock.sleep(for: .seconds(1))
          await send(.reload)
        }

      case .addButtonTapped:
        state.$entries.withLock {
          $0.insert(now, at: state.entries.firstIndex { now < $0 } ?? state.entries.endIndex)
        }
        return .none

      case .removeButtonTapped:
        if
          let nearest = state.entries.min(by: { abs($0.distance(to: now)) < abs($1.distance(to: now)) }),
          cal.isDate(nearest, inSameDayAs: now),
          let index = state.entries.firstIndex(of: nearest) {
          state.$entries.withLock {
            _ = $0.remove(at: index)
          }
        }

      case .binding: break
      }
      return .none
    }
  }

  @Dependency(\.continuousClock) var clock
  @Dependency(\.date.now) var now
  @Dependency(\.calendar) var cal

  public init() {}
}

public extension Dashboard.State {
  var dayAmount: Int {
    @Dependency(\.calculate.amount) var amount
    return amount(.day(now), entries.array)
  }

  var untilHereAmount: Int {
    @Dependency(\.calculate.amount) var amount
    @Dependency(\.calendar) var cal
    return amount(.to(cal.endOfDay(for: now)), entries.array)
  }

  var optionAmount: Int {
    @Dependency(\.calculate.amount) var amount
    return amount(amountOption.interval, entries.array)
  }

  var optionTime: TimeInterval {
    @Dependency(\.calculate) var calculate
    return switch timeOption {
    case .sinceLast: calculate.break(now, entries.array)
    case .longestBreak: calculate.longestBreak(now, entries.array)
    }
  }
}
