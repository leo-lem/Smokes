// Created by Leopold Lemmermann on 02.02.25.

import Calculate
import ComposableArchitecture
import Extensions
import Foundation
import Storage
import Types

@Reducer public struct Dashboard: Sendable {
  @ObservableState
  public struct State: Equatable {
    var entries: Dates
    var amountOption: AmountOption
    var timeOption: TimeOption

    var now: Date

    public init(
      entries: Dates = Dates(),
      amountOption: AmountOption = .week,
      timeOption: TimeOption = .sinceLast,
      now: Date = Dependency(\.date.now).wrappedValue
    ) {
      self.entries = entries
      self.amountOption = amountOption
      self.timeOption = timeOption
      self.now = now
    }
  }

  public enum Action: BindableAction, Sendable {
    case binding(BindingAction<State>)
    case onAppear
    case loaded(Dates, AmountOption, TimeOption)
    case reload
    case addButtonTapped
    case removeButtonTapped
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run { send in
          let entries = try storage.loadEntries()
          let amountOption = storage.loadAmountOption()
          let timeOption = storage.loadTimeOption()
          await send(.loaded(entries, amountOption, timeOption))
        }

      case let .loaded(entries, amountOption, timeOption):
        state.entries = entries
        state.amountOption = amountOption
        state.timeOption = timeOption
        return .none

      case .reload:
        state.now = now
        return .run { send in
          try? await clock.sleep(for: .seconds(1))
          await send(.reload)
        }

      case .addButtonTapped:
        return .run { [now] send in
          let entries = try storage.addEntry(now)
          let amountOption = storage.loadAmountOption()
          let timeOption = storage.loadTimeOption()
          await send(.loaded(entries, amountOption, timeOption))
        }

      case .removeButtonTapped:
        return .run { [now] send in
          let entries = try storage.removeNearestEntry(now)
          let amountOption = storage.loadAmountOption()
          let timeOption = storage.loadTimeOption()
          await send(.loaded(entries, amountOption, timeOption))
        }

      case .binding(\.amountOption):
        return .run { [option = state.amountOption] _ in
          storage.saveAmountOption(option)
        }

      case .binding(\.timeOption):
        return .run { [option = state.timeOption] _ in
          storage.saveTimeOption(option)
        }

      case .binding: break
      }
      return .none
    }
  }

  @Dependency(\.continuousClock) var clock
  @Dependency(\.date.now) var now
  @Dependency(\.calendar) var cal
  @Dependency(\.storage) var storage

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
