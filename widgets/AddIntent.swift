// Created by Leopold Lemmermann on 11.03.26.

import AppIntents
import Storage
import WidgetKit

struct AddSmokeIntent: AppIntent {
  static var title: LocalizedStringResource = "Add smoke"
  static var description = IntentDescription("Add a new smoke")
  static var openAppWhenRun = false

  @MainActor
  func perform() async throws -> some IntentResult {
    _ = try EntryStore.add(.now)
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}
