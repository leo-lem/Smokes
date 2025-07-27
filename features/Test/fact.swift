// Created by Leopold Lemmermann on 03.02.25.

import ComposableArchitecture
import class Foundation.URLSession
import Testing

@testable import Fact

@MainActor
struct FactTest {
  @Test
  func appear() async throws {
    let store = TestStore(initialState: Facts.State(), reducer: Facts.init) { deps in
      deps.continuousClock = ImmediateClock()
      deps.factsAPIClient = .testValue
    }
    store.exhaustivity = .off

    await store.send(.appear)
    await store.receive(\.fetch)

    await store.finish()
  }

  @Test
  func countdown() async throws {
    let clock = TestClock()
    let store = TestStore(initialState: Facts.State(progress: 0.90), reducer: Facts.init) { deps in
      deps.continuousClock = clock
      deps.dismiss = .init { #expect(true) }
    }

    await store.send(.countdown) { $0.progress += 0.01 }

    while store.state.progress <= 0.99 {
      await clock.advance(by: .milliseconds(50))
      await store.receive(\.countdown) { $0.progress += 0.01 }
    }

    await store.receive(\.dismiss)
  }
}
