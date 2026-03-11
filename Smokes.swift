// Created by Leopold Lemmermann on 28.04.23.

import App
import Storage
import SwiftUI
import TipKit
import Types

@main
struct Main: App {
  @State private var isReady = false

  var body: some Scene {
    WindowGroup {
      Group {
        if isReady {
          SmokesView()
        } else {
          HStack {
            ProgressView()
            Text("Migrating Data")
              .font(.title)
          }
          .padding()
          .background(Color.background, in: .capsule)
          .shadow(radius: 3)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background {
            Image(.noSmoking).resizable().scaledToFit()
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .background(Color(.background), ignoresSafeAreaEdges: .all)
          }
          .task(priority: .userInitiated) {
            do { try migrateEntriesToAppGroupIfNeeded() } catch { assertionFailure(error.localizedDescription) }
            isReady = true
          }
        }
      }
    }
  }

  init() {
    do {
      if CommandLine.arguments.contains("UI_TESTS") {
#if DEBUG
        try? FileManager.default.removeItem(at: .documentsDirectory.appending(path: "entries.json"))
        try? FileManager.default.removeItem(at: AppGroup.containerURL.appending(path: "entries.json"))
        UserDefaults.resetStandardUserDefaults()
#endif
      } else {
        try Tips.configure([
          .displayFrequency(.hourly)
        ])
      }
    } catch {
      print(error.localizedDescription)
    }
  }

  private func migrateEntriesToAppGroupIfNeeded() throws {
    let oldURL = URL.documentsDirectory.appending(path: "entries.json")
    let newURL = AppGroup.containerURL.appending(path: "entries.json")

    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: oldURL.path()) else { return }
    guard !fileManager.fileExists(atPath: newURL.path()) else { return }

    let data = try Data(contentsOf: oldURL)
    _ = try JSONDecoder().decode(Dates.self, from: data)
    try data.write(to: newURL, options: .atomic)
  }
}
