// Created by Leopold Lemmermann on 13.02.25.

import Foundation

public struct FactsAPIClient: Sendable {
  public var fetch: @Sendable (URL) async throws -> Fact

  public enum Error: Swift.Error, Equatable {
    case session(String)
    case unknownResponse(URLResponse)
    case unexpected(Int, HTTPURLResponse)
    case decoding(Data)
  }
}

public struct Fact: Equatable, Codable, Sendable {
  let fact: String
  let source: String
}
