// Created by Leopold Lemmermann on 02.02.25.

import ComposableArchitecture
import Extensions
import SwiftUIComponents
import SwiftUIExtensions

public struct DashboardView: View {
  @Bindable public var store: StoreOf<Dashboard>
  public var transfer: () -> Void

  public var body: some View {
    Grid {
      LoadableWithDescription(
        String(localizable: .smokesLld(store.dayAmount)),
        description: String(localizable: .today)
      )
      .widgetStyle()

      GridRow {
        LoadableWithDescription(
          String(localizable: .smokesLld(store.optionAmount)),
          description: store.amountOption.label
        )
        .widgetStyle(Binding(store.$amountOption))
        .popoverTip(OptionTip())

        LoadableWithDescription(
          store.optionTime.isFinite ? store.optionTime.formatted(.timeInterval) : String(localizable: .noData),
          description: store.timeOption.label
        )
        .widgetStyle(Binding(store.$timeOption))
      }

      GridRow {
        LoadableWithDescription(
          String(localizable: .smokesLld(store.untilHereAmount)),
          description: String(localizable: .untilNow)
        )
        .overlay(alignment: .bottomLeading) {
          Button(.localizable(.openExporter), systemImage: "folder", action: transfer)
            .labelStyle(.iconOnly)
            .accessibilityIdentifier("show-porter-button")
            .popoverTip(TransferTip())
        }
        .widgetStyle()

        IncrementMenu(decrementDisabled: store.dayAmount <= 0) {
          store.send(.addButtonTapped, animation: .default)
        } remove: {
          store.send(.removeButtonTapped, animation: .default)
        }
        .widgetStyle()
      }
    }
    .animation(.default, value: .combine(store.optionAmount, store.optionTime))
    .onAppear { store.send(.reload) }
  }

  public init(store: StoreOf<Dashboard>, transfer: @escaping () -> Void = {}) {
    self.store = store
    self.transfer = transfer
  }
}

#Preview {
  DashboardView(store: Store(initialState: Dashboard.State(), reducer: Dashboard.init))
    .padding()
}
