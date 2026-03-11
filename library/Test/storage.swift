// Created by Leopold Lemmermann on 11.03.26.

import Dependencies
import Foundation
@testable import Storage
import Testing
import Types

@MainActor
@Suite(.serialized)
struct StorageTests {
  final class Box: @unchecked Sendable {
    private let lock = NSLock()

    private var _entries = Dates()
    private var _amountOption = AmountOption.week
    private var _timeOption = TimeOption.sinceLast

    var entries: Dates {
      lock.lock()
      defer { lock.unlock() }
      return _entries
    }

    var amountOption: AmountOption {
      lock.lock()
      defer { lock.unlock() }
      return _amountOption
    }

    var timeOption: TimeOption {
      lock.lock()
      defer { lock.unlock() }
      return _timeOption
    }

    func save(entries: Dates) {
      lock.lock()
      defer { lock.unlock() }
      _entries = entries
    }

    func save(amountOption: AmountOption) {
      lock.lock()
      defer { lock.unlock() }
      _amountOption = amountOption
    }

    func save(timeOption: TimeOption) {
      lock.lock()
      defer { lock.unlock() }
      _timeOption = timeOption
    }
  }

  private let date = Date(timeIntervalSinceReferenceDate: 1_000_000)

  private func makeStorage(box: Box = Box()) -> (Storage, Box) {
    let storage = Storage(
      loadEntries: {
        box.entries
      },
      saveEntries: { entries in
        box.save(entries: entries)
      },
      loadAmountOption: {
        box.amountOption
      },
      saveAmountOption: { option in
        box.save(amountOption: option)
      },
      loadTimeOption: {
        box.timeOption
      },
      saveTimeOption: { option in
        box.save(timeOption: option)
      },
      addEntry: { newDate in
        var entries = box.entries
        entries.insert(newDate, at: entries.firstIndex { newDate < $0 } ?? entries.endIndex)
        box.save(entries: entries)
        return entries
      },
      removeNearestEntry: { target in
        var entries = box.entries

        guard
          let nearest = entries.min(by: { abs($0.distance(to: target)) < abs($1.distance(to: target)) }),
          Calendar.current.isDate(nearest, inSameDayAs: target),
          let index = entries.firstIndex(of: nearest)
        else {
          return entries
        }

        entries.remove(at: index)
        box.save(entries: entries)
        return entries
      }
    )

    return (storage, box)
  }

  @Test func previewValue_hasExpectedDefaults() throws {
    #expect(try Storage.previewValue.loadEntries() == Dates())
    #expect(Storage.previewValue.loadAmountOption() == .month)
    #expect(Storage.previewValue.loadTimeOption() == .longestBreak)

    let added = try Storage.previewValue.addEntry(date)
    #expect(added == Dates([date]))

    let removed = try Storage.previewValue.removeNearestEntry(date)
    #expect(removed == Dates())
  }

  @Test func saveAndLoadEntries_roundTrips() throws {
    let (storage, _) = makeStorage()
    let entries = Dates([date, date.addingTimeInterval(-3600)])

    try storage.saveEntries(entries)

    #expect(try storage.loadEntries() == entries)
  }

  @Test func saveAndLoadOptions_roundTrip() {
    let (storage, _) = makeStorage()

    storage.saveAmountOption(.year)
    storage.saveTimeOption(.longestBreak)

    #expect(storage.loadAmountOption() == .year)
    #expect(storage.loadTimeOption() == .longestBreak)
  }

  @Test func addEntry_insertsIntoSortedEntries() throws {
    let (storage, box) = makeStorage()
    let earlier = date.addingTimeInterval(-3600)
    let later = date.addingTimeInterval(3600)

    box.save(entries: Dates([earlier, date]))

    let updated = try storage.addEntry(later)

    #expect(updated == Dates([earlier, date, later]))
    #expect(box.entries == Dates([earlier, date, later]))
  }

  @Test func removeNearestEntry_removesClosestEntryOnSameDay() throws {
    let (storage, box) = makeStorage()
    let earlier = date.addingTimeInterval(-1800)
    let later = date.addingTimeInterval(1200)
    let otherDay = date.addingTimeInterval(86400)

    box.save(entries: Dates([later, date, earlier, otherDay]))

    let updated = try storage.removeNearestEntry(date.addingTimeInterval(900))

    #expect(updated == Dates([date, earlier, otherDay]))
    #expect(box.entries == Dates([date, earlier, otherDay]))
  }

  @Test func removeNearestEntry_doesNothingWhenNoEntryIsOnSameDay() throws {
    let (storage, box) = makeStorage()
    let otherDay = date.addingTimeInterval(86400)

    box.save(entries: Dates([otherDay]))

    let updated = try storage.removeNearestEntry(date)

    #expect(updated == Dates([otherDay]))
    #expect(box.entries == Dates([otherDay]))
  }

  @Test func dependencyValue_usesInjectedStorage() throws {
    let (injected, box) = makeStorage()
    let expected = Dates([date])

    box.save(entries: expected)
    box.save(amountOption: .month)
    box.save(timeOption: .longestBreak)

    withDependencies {
      $0.storage = injected
    } operation: {
      @Dependency(\.storage) var storage

      #expect((try? storage.loadEntries() == expected) ?? false)
      #expect(storage.loadAmountOption() == .month)
      #expect(storage.loadTimeOption() == .longestBreak)
    }
  }
}
