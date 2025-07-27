// Created by Leopold Lemmermann on 03.02.25.

import ComposableArchitecture
import Extensions
import Foundation

@Reducer public struct Facts {
  @ObservableState public struct State: Equatable, Sendable {
    @Shared var fact: Fact
    var progress = 0.0

    public init(fact: Fact? = nil, progress: Double = 0.0) {
      _fact = Shared(value: fact ?? Fact(fact: String(localizable: .comingSoon), source: "Smokes"))
      self.progress = progress
    }
  }

  public enum Action: Sendable {
    case countdown,
         fetch,
         appear,
         dismiss
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .appear:
        return .merge(.send(.countdown), .send(.fetch))

      case .dismiss:
        return .run { [dismiss] _ in
#if DEBUG
          @Dependency(\.isPresented) var isPresented
          if isPresented {
            await dismiss()
          }
#else
          await dismiss()
#endif
        }

      case .countdown:
        state.progress += 0.01
        return .run { [state, clock] send in
          guard state.progress <= 0.99 else { return await send(.dismiss) }
          try? await clock.sleep(for: .milliseconds(50))
          await send(.countdown)
        }

      case .fetch:
        return .run { [state, fetch] _ in
          do {
            let fact = try await fetch(Bundle.main[url: "FactsUrl"])
            state.$fact.withLock { $0 = fact }
          } catch {
            print("Failed to fetch fact: \(error)")
          }
        }
      }
    }
  }

  @Dependency(\.factsAPIClient.fetch) var fetch
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.continuousClock) var clock

  public init() {}
}
