// Created by Leopold Lemmermann on 09.02.25.

import ComposableArchitecture
import Testing
import Types

@testable import Statistic

@MainActor
struct StatisticTest {
  @Test
  func interval() async throws {
    let store = TestStore(
      initialState: Statistic.State(selection: .alltime, option: .permonth, plotOption: .bymonth),
      reducer: Statistic.init
    ) { deps in
      deps.calendar = .current
    }

    await withDependencies {
      $0.calendar = .current
    } operation: {
      await store.send(.binding(.set(\.$selection, .init(value: .month(.distantPast))))) {
        $0.$selection.withLock { $0 = .month(.distantPast) }
        $0.$option.withLock { $0 = .perday }
        $0.$plotOption.withLock { $0 = .byday }
      }
    }
  }

  @Test
  func computations() async throws {
    let store = TestStore(
      initialState: Statistic.State(selection: .month(.distantPast)),
      reducer: Statistic.init
    )

    withDependencies { deps in
      deps.date.now = .distantPast
      deps.calendar = .current
      deps.calculate.average = { _, _, _ in 1.0 }
      deps.calculate.trend = { _, _, _ in 1.0 }
      deps.calculate.amounts = { _, _, _ in [.alltime: 1] }
      deps.calculate.averageBreak = { _, _ in 1.0 }
    } operation: {
      #expect(store.state.optionAverage == 1.0)
      #expect(store.state.optionTrend == 1.0)
      #expect(store.state.optionPlotData?.first?.0 == .alltime)
      #expect(store.state.optionPlotData?.first?.1 == 1)
      #expect(store.state.averageTimeBetween == 1.0)
    }
  }

  @Test(arguments: [Interval.alltime, .month(.distantPast), .year(.distantPast)])
  func showingTrend(_ interval: Interval) async throws {
    let store = TestStore(
      initialState: Statistic.State(selection: interval),
      reducer: Statistic.init
    )

    store.state.$selection.withLock { $0 = interval }

    #expect(interval == .alltime || store.state.showingTrend)
  }
}
