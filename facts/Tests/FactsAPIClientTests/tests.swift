// Created by Leopold Lemmermann on 13.02.25.

@testable import FactsAPIClient
import Dependencies
import Foundation
import Testing

@Suite(.serialized)
struct Test {
  @Dependency(\.factsAPIClient) var client
  let url = URL.documentsDirectory
  var urlSession: URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockProtocol.self]
    return URLSession(configuration: config)
  }

  @Test func correctResponse() async throws {
    try await withDependencies {
      $0.factsAPIClient = .liveValue
      $0.urlSession = urlSession
    } operation: {
      let fact = "This is a fact!"

      MockProtocol.handler = { request in
        return (
          fact.data(using: .utf8)!,
          HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: [:])!
        )
      }

      let response = try await client.fetch(url)
      #expect(response == fact)
    }
  }

  @Test func sessionError() async throws {
    await withDependencies {
      $0.factsAPIClient = .liveValue
      $0.urlSession = urlSession
    } operation: {
      MockProtocol.handler = { _ in
        throw URLError(.badServerResponse)
      }

      await #expect(throws: FactsAPIClient.Error.session(URLError(.badServerResponse).localizedDescription)) {
        try await client.fetch(url)
      }
    }
  }

  @Test func unknownResponse() async throws {
    try await withDependencies {
      $0.factsAPIClient = .liveValue
      $0.urlSession = urlSession
    } operation: {
      let response = URLResponse(url: .documentsDirectory, mimeType: "", expectedContentLength: 0, textEncodingName: "")

      MockProtocol.handler = { request in
        return (Data(), response)
      }

      do {
        _ = try await client.fetch(url)
      } catch let error as FactsAPIClient.Error {
        if case .unknownResponse = error {
          #expect(true)
        } else {
          Issue.record(error)
        }
      }
    }
  }

  @Test func unexpectedStatusCode() async throws {
    try await withDependencies {
      $0.factsAPIClient = .liveValue
      $0.urlSession = urlSession
    } operation: {
      MockProtocol.handler = { request in
        return (
          Data(),
          HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: [:])!
        )
      }

      do {
        _ = try await client.fetch(url)
      } catch let error as FactsAPIClient.Error {
        if case let .unexpected(code, _) = error {
          #expect(code == 404)
        } else {
          Issue.record(error)
        }
      }
    }
  }

  @Test func decodingError() async throws {
    await withDependencies {
      $0.factsAPIClient = .liveValue
      $0.urlSession = urlSession
    } operation: {
      let data = "This is a fact!".data(using: .unicode)!

      MockProtocol.handler = { request in
        return (data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: [:])!)
      }

      await #expect(throws: FactsAPIClient.Error.decoding(data)) {
        try await client.fetch(url)
      }
    }
  }

  @Test func testValue() async throws {
    try await withDependencies {
      $0.urlSession = urlSession
    } operation: {
      let fact = try await client.fetch(url)
      #expect(fact == "This is an example fact!")
    }
  }
}

private class MockProtocol: URLProtocol {
  nonisolated(unsafe) static var handler: ((URLRequest) throws -> (Data, URLResponse))!

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func stopLoading() { }
  override func startLoading() {
    do {
      let (data, response) = try MockProtocol.handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }
}
