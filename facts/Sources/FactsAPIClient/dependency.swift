// Created by Leopold Lemmermann on 13.02.25.

import Dependencies

extension FactsAPIClient: DependencyKey {
  public static let liveValue: Self = FactsAPIClient(
    fetch: Self.fetch
  )

  public static let testValue: Self = FactsAPIClient(
    fetch: { _ in return "This is an example fact!" }
  )
}

public extension DependencyValues {
  var factsAPIClient: FactsAPIClient {
    get { self[FactsAPIClient.self] }
    set { self[FactsAPIClient.self] = newValue }
  }
}
