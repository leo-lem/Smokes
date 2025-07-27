// Created by Leopold Lemmermann on 30.04.23.

import Vapor

extension Application {
  @discardableResult
  func configure(_ facts: Facts) -> Self {
    get { _ in
      "Welcome to Smokes' Facts API! Facts are at /{languageCode}…"
    }

    get(":lang") { req in
      guard let fact = facts.random(for: req.parameters.get("lang")!) else { throw Abort(.notFound) }
      return fact
    }

    return self
  }
}
