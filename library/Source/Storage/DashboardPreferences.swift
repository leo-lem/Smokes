// Created by Leopold Lemmermann on 11.03.26.

import Foundation
import Types

public enum DashboardPreferences {
  private enum Key {
    static let amountOption = "dashboard_amountOption"
    static let timeOption = "dashboard_timeOption"
  }

  public static var amountOption: AmountOption {
    get {
      guard
        let rawValue = AppGroup.defaults.string(forKey: Key.amountOption),
        let option = AmountOption(rawValue: rawValue)
      else {
        return .week
      }

      return option
    }
    set {
      AppGroup.defaults.set(newValue.rawValue, forKey: Key.amountOption)
    }
  }

  public static var timeOption: TimeOption {
    get {
      guard
        let rawValue = AppGroup.defaults.string(forKey: Key.timeOption),
        let option = TimeOption(rawValue: rawValue)
      else {
        return .sinceLast
      }

      return option
    }
    set {
      AppGroup.defaults.set(newValue.rawValue, forKey: Key.timeOption)
    }
  }
}
