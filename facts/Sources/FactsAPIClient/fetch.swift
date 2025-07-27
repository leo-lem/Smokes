// Created by Leopold Lemmermann on 13.02.25.

import struct Dependencies.Dependency
import Foundation

public extension FactsAPIClient {
  static func fetch(_ url: URL) async throws -> String {
    @Dependency(\.urlSession) var session

    let url = url.appendingPathComponent(Locale.current.identifier)

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

    guard let fact = String(data: data, encoding: .utf8) else {
      throw Error.decoding(data)
    }

    return fact
  }
}
