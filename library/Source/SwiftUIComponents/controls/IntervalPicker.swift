// Created by Leopold Lemmermann on 08.03.23.

import struct Dependencies.Dependency
import Extensions
import SwiftUI
import Types

public struct IntervalPicker: View {
  @Binding var selection: Interval
  let bounds: Interval

  public var body: some View {
    HStack {
      Button {
        if selectedMonth != nil { selectedMonth = previous } else { selectedYear ?= previous }
      } label: {
        Label(.localizable(.previous), systemImage: "chevron.left")
      }
      .disabled(previous == nil)
      .accessibilityIdentifier("previous-button")

      Picker(String(localizable: .month), selection: $selectedMonth) {
        Text(localizable: .none)
          .tag(Interval?.none)

        ForEach(months, id: \.self) { month in
          Text(month.end!.formatted(Date.FormatStyle().month(.abbreviated)))
            .tag(month)
        }
      }
      .highlight(when: !selectedAlltime && selectedMonth != nil)

      Picker(String(localizable: .year), selection: $selectedYear) {
        ForEach(years, id: \.self) { year in
          Text(year.end!.formatted(Date.FormatStyle().year(.defaultDigits)))
            .tag(year)
        }
      }
      .highlight(when: !selectedAlltime)

      Button(.localizable(.next), systemImage: "chevron.right") {
        if selectedMonth != nil { selectedMonth = next } else { selectedYear ?= next }
      }
      .disabled(next == nil)
      .accessibilityIdentifier("next-button")

      Spacer()

      Button(.localizable(.untilNow), systemImage: "chevron.forward.to.line") { selectedAlltime.toggle() }
        .highlight(when: selectedAlltime)
    }
    .minimumScaleFactor(0.5)
    .lineLimit(1)
    .animation(.default, value: .combine(selection, selectedMonth, selectedYear, selectedAlltime))
    .onChange(of: selectedMonth) { _, new in
      selectedAlltime = false

      guard let month = new else { return selection = selectedYear }

      selectedYear = .year(month.end!)

      if month.start! > upperBound || month.end! < lowerBound {
        selectedMonth = nil
        selection = selectedYear
      } else {
        selection = month
      }
    }
    .onChange(of: selectedYear) { _, new in
      if case .year = selection {
        selectedMonth = nil
        selection = new
      }
    }
    .onChange(of: selectedAlltime) { _, new in
      if new { selection = .alltime } else { selection = selectedMonth ?? selectedYear }
    }
  }

  @State private var selectedMonth: Interval?
  @State private var selectedYear: Interval
  @State private var selectedAlltime: Bool

  private let lowerBound: Date
  private let upperBound: Date

  public init(selection: Binding<Interval>, bounds: Interval) {
    guard let start = bounds.start, let end = bounds.end else { fatalError("IntervalPicker requires bounds.") }
    self.bounds = bounds

    _selection = selection
    _selectedMonth = .init(initialValue: .month(bounds.end!))
    _selectedYear = .init(initialValue: .year(bounds.end!))
    _selectedAlltime = .init(initialValue: selection.wrappedValue == .alltime)

    lowerBound = start
    upperBound = end
  }
}

extension IntervalPicker {
  private var previous: Interval? { (selectedMonth ?? selectedYear).previous(in: bounds) }
  private var next: Interval? { (selectedMonth ?? selectedYear).next(in: bounds) }

  private var years: [Interval] { bounds.enumerate(by: .year) ?? [] }
  private var months: [Interval] { selectedYear.enumerate(by: .month, in: bounds) ?? [] }
}

private extension View {
  func highlight(when isSelected: Bool) -> some View {
    shadow(color: .primary, radius: isSelected ? 5 : 0)
  }
}

#Preview {
  @Previewable @State var selected = Interval.alltime

  IntervalPicker(
    selection: $selected,
    bounds: .fromTo(.init(start: .init(timeIntervalSinceReferenceDate: 9_999_999), duration: 99_999_999))
  )
  .buttonStyle(.borderedProminent)
  .labelStyle(.iconOnly)
  .padding()
}
