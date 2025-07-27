// Created by Leopold Lemmermann on 01.04.23.

import SwiftUI

public struct LoadableWithDescription<V: CustomStringConvertible, Content: View>: View {
  let value: V?
  let description: LocalizedStringKey?
  let content: (V) -> Content

  public var body: some View {
    VStack {
      Spacer()

      if let value {
        content(value)
      } else {
        ProgressView()
      }

      Spacer()

      if let description {
        Text(description)
          .font(.subheadline)
          .italic()
          .minimumScaleFactor(0.8)
          .lineLimit(1)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .accessibilityElement()
    .accessibilityLabel(description ?? .localizable(.noDescription))
    .accessibilityValue(value?.description ?? String(localizable: .loading))
  }

  public init(
    _ value: V?,
    description: String? = nil,
    @ViewBuilder content: @escaping (V) -> Content
  ) {
    self.value = value
    self.description = description.flatMap { LocalizedStringKey($0) }
    self.content = content
  }
}

extension LoadableWithDescription where Content == AnyView {
  public init<CollectionContent: View>(
    collection: V?,
    description: String?,
    @ViewBuilder content: @escaping (V) -> CollectionContent
  ) where V: Collection {
    self.init(collection, description: description) {
      AnyView(erasing: content($0))
    }
  }

  public init(
    _ value: String?,
    description: String? = nil
  ) where V == String {
    self.init(value, description: description) {
      AnyView(erasing:
        Text($0)
          .font(.largeTitle)
          .minimumScaleFactor(0.7)
          .transition(.push(from: .top))
          .lineLimit(1)
      )
    }
  }
}

import Charts

#Preview {
  HStack {
    LoadableWithDescription("Hello", description: "Some description")
    LoadableWithDescription(nil, description: "Some description")
  }
  .frame(maxHeight: 200)
}

#Preview("Chart") {
  LoadableWithDescription(collection: [Int](), description: "Some description") { _ in
    Chart {
      BarMark(x: .value("amount", 1))
      BarMark(x: .value("amount", 2))
    }
    .chartYAxisLabel("smokes")
  }
}
