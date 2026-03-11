// Created by Leopold Lemmermann on 11.03.26.

import Foundation

public enum AppGroup {
  public static let identifier = "group.dev.leolem.smokes"

  public static var defaults: UserDefaults {
    guard let defaults = UserDefaults(suiteName: identifier) else {
      preconditionFailure("Missing app group defaults for \(identifier)")
    }

    return defaults
  }

  public static var containerURL: URL {
    guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
      preconditionFailure("Missing app group container for \(identifier)")
    }

    return url
  }
}
