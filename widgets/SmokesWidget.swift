// Created by Leopold Lemmermann on 11.03.26.

import AppIntents
import Calculate
import Dependencies
import Storage
import SwiftUI
import SwiftUIExtensions
import Types
import WidgetKit

struct SmokesEntry: TimelineEntry {
  let date: Date
  let configuration: SmokesWidgetIntent
  let amount: Int
  let time: TimeInterval
}

struct SmokesProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SmokesEntry {
    SmokesEntry(
      date: .now,
      configuration: SmokesWidgetIntent(),
      amount: 5,
      time: 3600
    )
  }

  func snapshot(for configuration: SmokesWidgetIntent, in context: Context) async -> SmokesEntry {
    entry(for: configuration, date: .now)
  }

  func timeline(for configuration: SmokesWidgetIntent, in context: Context) async -> Timeline<SmokesEntry> {
    let entry = entry(for: configuration, date: .now)
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now.addingTimeInterval(900)
    return Timeline(entries: [entry], policy: .after(nextUpdate))
  }

  private func entry(for configuration: SmokesWidgetIntent, date: Date) -> SmokesEntry {
    let entries = (try? EntryStore.load()) ?? Dates()

    @Dependency(\.calculate.amount) var amount
    @Dependency(\.calculate) var calculate

    let amountValue = configuration.amountOption.amount(in: entries)
    let timeValue = configuration.timeOption.time(at: date, in: entries)

    return SmokesEntry(
      date: date,
      configuration: configuration,
      amount: amountValue,
      time: timeValue
    )
  }
}

struct SmokesWidgetView: View {
  let entry: SmokesProvider.Entry
  @Environment(\.widgetFamily) private var family

  var body: some View {
    switch family {
    case .systemSmall:
      small
    case .systemMedium:
      medium
    default:
      small
    }
  }

  private var small: some View {
    VStack(spacing: 0) {
      Text(entry.configuration.amountOption.label)
        .font(.caption)
        .foregroundStyle(.secondary)

      Spacer()

      Text("\(entry.amount)")
        .font(.system(size: 80, weight: .bold, design: .rounded))
        .lineLimit(1)
        .minimumScaleFactor(0.1)

      Spacer()

      HStack {

        Image(.noSmoking)
          .resizable()
          .frame(width: 50, height: 50)

        Spacer()

        Button(.addSmoke, systemImage: "plus", intent: AddSmokeIntent())
          .labelStyle(.iconOnly)
          .buttonStyle(.plain)
          .frame(width: 45, height: 45)
          .font(.system(size: 40, weight: .bold))
          .foregroundStyle(.widgetBackground)
          .background(.accent, in: .circle)
      }
    }
    .containerBackground(.widgetBackground, for: .widget)
  }

  private var medium: some View {
    VStack(spacing: 0) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 0) {
          Text(entry.configuration.amountOption.label)
            .font(.caption)
            .foregroundStyle(.secondary)

          Text("\(entry.amount)")
            .font(.system(size: 80, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 0) {
          Text(entry.configuration.timeOption.label)
            .font(.caption)
            .foregroundStyle(.secondary)

          Text(entry.time.isFinite ? entry.time.formatted(.timeInterval) : String(localized: .noData))
            .font(.title.weight(.bold))
            .lineLimit(1)
        }
      }

      Spacer()

      HStack {
        Image(.noSmoking)
          .resizable()
          .frame(width: 50, height: 50)

        Spacer()

        Button(.addSmoke, systemImage: "plus", intent: AddSmokeIntent())
          .buttonStyle(.plain)
          .font(.headline.weight(.bold))
          .foregroundStyle(.widgetBackground)
          .frame(height: 50)
          .padding(.horizontal, 20)
          .background(.accent, in: Capsule())
      }
    }
    .containerBackground(.widgetBackground, for: .widget)
  }
}

struct SmokesWidget: Widget {
  let kind = "SmokesWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: SmokesWidgetIntent.self,
      provider: SmokesProvider()
    ) { entry in
      SmokesWidgetView(entry: entry)
    }
    .configurationDisplayName("Smokes")
    .description("Track your count and add a smoke quickly.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct SmokesWidgetBundle: WidgetBundle {
  var body: some Widget {
    SmokesWidget()
  }
}

#Preview("Small Empty", as: .systemSmall) {
  SmokesWidget()
} timeline: {
  SmokesEntry(
    date: .now,
    configuration: {
      let intent = SmokesWidgetIntent()
      intent.widgetAmountOption = .today
      intent.widgetTimeOption = .sinceLast
      return intent
    }(),
    amount: 40102,
    time: 0
  )
}

#Preview("Medium Month", as: .systemMedium) {
  SmokesWidget()
} timeline: {
  SmokesEntry(
    date: .now,
    configuration: {
      let intent = SmokesWidgetIntent()
      intent.widgetAmountOption = .month
      intent.widgetTimeOption = .sinceLast
      return intent
    }(),
    amount: 42202,
    time: 5_400
  )
}
