// Created by Leopold Lemmermann on 09.02.25.

import ComposableArchitecture
import struct Foundation.Date
import Testing
import Types

@testable import Dashboard
@testable import Storage

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
      deps.storage = Storage(
        loadEntries: { Dates() },
        saveEntries: { _ in },
        loadAmountOption: { .week },
        saveAmountOption: { _ in },
        loadTimeOption: { .sinceLast },
        saveTimeOption: { _ in },
        addEntry: { Dates([$0]) },
        removeNearestEntry: { _ in Dates() }
      )
    }

    await store.send(.addButtonTapped)
    await store.receive(\.loaded) {
      $0.entries = Dates([now])
      $0.amountOption = .week
      $0.timeOption = .sinceLast
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
      deps.storage = Storage(
        loadEntries: { Dates([now, next]) },
        saveEntries: { _ in },
        loadAmountOption: { .week },
        saveAmountOption: { _ in },
        loadTimeOption: { .sinceLast },
        saveTimeOption: { _ in },
        addEntry: { _ in Dates([now, next]) },
        removeNearestEntry: { _ in Dates([now]) }
      )
    }

    await store.send(.removeButtonTapped)
    await store.receive(\.loaded) {
      $0.entries = Dates([now])
      $0.amountOption = .week
      $0.timeOption = .sinceLast
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
      deps.storage = .previewValue
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

  @Test
  func loadingOnAppear() async throws {
    let now = Date.now

    let store = TestStore(
      initialState: Dashboard.State(now: now),
      reducer: Dashboard.init
    ) { deps in
      deps.storage = Storage(
        loadEntries: { Dates([now]) },
        saveEntries: { _ in },
        loadAmountOption: { .month },
        saveAmountOption: { _ in },
        loadTimeOption: { .longestBreak },
        saveTimeOption: { _ in },
        addEntry: { _ in Dates() },
        removeNearestEntry: { _ in Dates() }
      )
    }

    await store.send(.onAppear)
    await store.receive(\.loaded) {
      $0.entries = Dates([now])
      $0.amountOption = .month
      $0.timeOption = .longestBreak
    }
  }
}
