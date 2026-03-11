// Created by Leopold Lemmermann on 11.03.26.

import Foundation
import Types

public enum EntryStore {
  public static var fileURL: URL {
    AppGroup.containerURL.appending(path: "entries.json")
  }

  public static func load() throws -> Dates {
    guard FileManager.default.fileExists(atPath: fileURL.path()) else {
      return Dates()
    }

    let data = try Data(contentsOf: fileURL)
    return try JSONDecoder().decode(Dates.self, from: data)
  }

  public static func save(_ entries: Dates) throws {
    let data = try JSONEncoder().encode(entries)
    try data.write(to: fileURL, options: .atomic)
  }

  @discardableResult
  public static func add(_ date: Date) throws -> Dates {
    var entries = try load()
    entries.insert(date, at: entries.firstIndex { date < $0 } ?? entries.endIndex)
    try save(entries)
    return entries
  }

  @discardableResult
  public static func removeNearest(to date: Date, calendar: Calendar = .current) throws -> Dates {
    var entries = try load()

    guard
      let nearest = entries.min(by: { abs($0.distance(to: date)) < abs($1.distance(to: date)) }),
      calendar.isDate(nearest, inSameDayAs: date),
      let index = entries.firstIndex(of: nearest)
    else {
      return entries
    }

    entries.remove(at: index)
    try save(entries)
    return entries
  }
}
