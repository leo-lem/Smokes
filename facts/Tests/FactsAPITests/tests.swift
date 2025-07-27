// Created by Leopold Lemmermann on 13.02.25.

@testable import FactsAPI
import Testing
import VaporTesting

struct FactsAPITests {
  @Test func whenCallingRoot_thenReturnsSomething() async throws {
    try await withApp { app in
      try await app.testing().test(.GET, "") { response in
        #expect(response.status == .ok)
        #expect(!response.body.string.isEmpty)
      }
    }
  }

  @Test func whenGettingEnglishFact_thenReturnsSomething() async throws {
    try await withApp { app in
      try await app.testing().test(.GET, "en") { response in
        #expect(response.status == .ok)
        #expect(!response.body.string.isEmpty)
      }
    }
  }
  
  @Test func whenGettingGermanFact_thenReturnsSomething() async throws {
    try await withApp { app in
      try await app.testing().test(.GET, "de") { response in
        #expect(response.status == .ok)
        #expect(!response.body.string.isEmpty)
      }
    }
  }

  private func withApp(_ test: (Application) async throws -> ()) async throws {
    let app = try await Application.make(.testing)
    do {
      app.configure(Facts())
      try await test(app)
    } catch {
      try await app.asyncShutdown()
      throw error
    }
    try await app.asyncShutdown()
  }
}
