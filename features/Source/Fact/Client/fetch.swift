// Created by Leopold Lemmermann on 13.02.25.

import struct Dependencies.Dependency
import Foundation

public extension FactsAPIClient {
  static func fetch(_ url: URL) async throws -> Fact {
    @Dependency(\.urlSession) var session
    let decoder = JSONDecoder()

    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await session.data(from: url)
    } catch {
      throw Error.session(error.localizedDescription)
    }

    guard let response = response as? HTTPURLResponse else {
      throw Error.unknownResponse(response)
    }

    guard response.statusCode == 200 else {
      throw Error.unexpected(response.statusCode, response)
    }

    do {
      return try decoder.decode(Fact.self, from: data)
    } catch {
      throw Error.decoding(data)
    }
  }
}
