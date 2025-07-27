// Created by Leopold Lemmermann on 12.03.23.

import Charts
import ComposableArchitecture
import Extensions
import SwiftUIComponents
import SwiftUIExtensions

public struct StatisticView: View {
  @Bindable public var store: StoreOf<Statistic>

  public var body: some View {
    Grid {
      LoadableWithDescription(
        store.optionAverage.flatMap{String(localizable: $0.isFinite ? .smokes($0.formatted(.average)) : .noData)},
        description: store.option.rawValue
      )
      .widgetStyle($store.option, enabled: store.enabledOptions)

      LoadableWithDescription(
        store.optionPlotData?
          .sorted(by: \.key)
          .map { ($0.formatted(.interval(bounds: store.selection, subdivision: store.subdivision)), $1) },
        description: store.plotOption.rawValue
      ) {
        AmountsChart($0)
      }
      .widgetStyle($store.plotOption, enabled: store.enabledPlotOptions)
      .gridCellColumns(2)

      GridRow {
        LoadableWithDescription(
          store.averageTimeBetween.isFinite
          ? store.averageTimeBetween.formatted(.timeInterval)
          : String(localizable: .noData),
          description: String(localizable: .timeBetween)
        )
        .widgetStyle()
        .gridCellColumns(store.showingTrend ? 1 : 2)

        if store.showingTrend {
          LoadableWithDescription(
            store.optionTrend.flatMap{String(localizable: $0.isFinite ? .smokes($0.formatted(.trend)) : .noData)},
            description: String(localizable: .trend(store.option.rawValue))
          )
          .widgetStyle()
          .transition(.move(edge: .trailing))
        }
      }

      IntervalPicker(selection: $store.selection, bounds: store.bounds)
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)
        .widgetStyle()
        .popoverTip(AlltimeTip())
    }
    .animation(.default, value: .combine(store.selection, store.option, store.plotOption))
  }

  public init(store: StoreOf<Statistic>) { self.store = store }
}

#Preview {
  StatisticView(store: Store(initialState: Statistic.State(), reducer: Statistic.init))
    .padding()
}
