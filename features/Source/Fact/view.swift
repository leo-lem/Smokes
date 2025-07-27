// Created by Leopold Lemmermann on 26.03.23.

import ComposableArchitecture
import Extensions
import SwiftUI

public struct FactView: View {
  let store: StoreOf<Facts>

  public var body: some View {
    VStack {
      VStack {
        Text(store.fact.fact)
          .font(.headline)
          .multilineTextAlignment(.center)
          .minimumScaleFactor(0.7)

        Color.accentColor
          .frame(maxWidth: 100, maxHeight: 2)
          .cornerRadius(2)

        Text(store.fact.source)
          .font(.subheadline)
      }
      .frame(maxWidth: .infinity)
      .padding(5)
      .background(.ultraThinMaterial)
      .cornerRadius(5)

      Spacer()

      HStack {
        ProgressView(value: store.progress)
          .padding(5)
          .background(.ultraThinMaterial)
          .cornerRadius(5)

        Button(.localizable(.skip), systemImage: "chevron.forward.to.line") {
          store.send(.dismiss, animation: .default)
        }
        .buttonStyle(.borderedProminent)
        .labelStyle(.iconOnly)
      }
    }
    .onAppear { store.send(.appear, animation: .default) }
  }

  public init(store: StoreOf<Facts>) { self.store = store }
}

#Preview {
  FactView(store: Store(initialState: Facts.State(), reducer: Facts.init))
}
