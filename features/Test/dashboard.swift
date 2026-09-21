// Created by Leopold Lemmermann on 09.02.25.

import ComposableArchitecture
import struct Foundation.Date
import Testing
import Types

@testable import Dashboard

@MainActor
struct DashboardTest {
  @Test
  func adding() async throws {
    let now = Date.now
    let store = TestStore(
      initialState: Dashboard.State(),
      reducer: Dashboard.init
    ) { deps in
      deps.date.now = now
    }

    await store.send(.addButtonTapped) {
      $0.$entries.withLock { $0 = Dates([now]) }
    }
  }

  @Test
  func removing() async throws {
    let now = Date.now
    let next = Date(timeIntervalSinceNow: 1)

    let store = TestStore(
      initialState: Dashboard.State(entries: Dates([now, next])),
      reducer: Dashboard.init
    ) { deps in
      deps.date.now = next
      deps.calendar = .current
    }

    await store.send(.removeButtonTapped) {
      $0.$entries.withLock { $0 = Dates([now]) }
    }
  }

  @Test
  func computing() async throws {
    let store = TestStore(
      initialState: Dashboard.State(),
      reducer: Dashboard.init
    ) { deps in
      deps.calendar = .current
      deps.date.now = .distantPast
      deps.calculate.amount = { _, _ in 1 }
      deps.calculate.break = { _, _ in 1 }
      deps.calculate.longestBreak = { _, _ in 1 }
    }
    
    withDependencies {
      $0.calendar = .current
      $0.date.now = .distantPast
      $0.calculate.amount = { _, _ in 1 }
      $0.calculate.break = { _, _ in 1 }
      $0.calculate.longestBreak = { _, _ in 1 }
    } operation: {
      #expect(store.state.dayAmount == 1)
      #expect(store.state.untilHereAmount == 1)
      #expect(store.state.optionAmount == 1)
      #expect(store.state.optionTime == 1)
    }
  }
}
