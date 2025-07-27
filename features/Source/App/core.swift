// Created by Leopold Lemmermann on 02.02.25.

import ComposableArchitecture
import Dashboard
import Fact
import History
import Info
import Statistic
import Transfer

@Reducer public struct Smokes: Sendable {
  @ObservableState public struct State: Equatable {
    var dashboard: Dashboard.State
    var history: History.State
    var statistic: Statistic.State

    @Presents var fact: Facts.State?
    @Presents var info: Info.State?
    @Presents var transfer: Transfer.State?

    var tab: Int

    public init(
      dashboard: Dashboard.State = Dashboard.State(),
      history: History.State = History.State(),
      statistic: Statistic.State = Statistic.State(),
      fact: Facts.State? = nil,
      info: Info.State? = nil,
      transfer: Transfer.State? = nil,
      tab: Int = 1
    ) {
      self.dashboard = dashboard
      self.history = history
      self.statistic = statistic
      _fact = .init(wrappedValue: fact)
      _info = .init(wrappedValue: info)
      _transfer = .init(wrappedValue: transfer)
      self.tab = tab
    }
  }

  public enum Action: ViewAction, Sendable {
    case dashboard(Dashboard.Action),
         history(History.Action),
         statistic(Statistic.Action),
         fact(PresentationAction<Facts.Action>),
         info(PresentationAction<Info.Action>),
         transfer(PresentationAction<Transfer.Action>)

    case view(View)
    @CasePathable public enum View: BindableAction, Sendable {
      case binding(BindingAction<State>)

      case infoButtonTapped
      case factButtonTapped
      case transferButtonTapped
    }
  }

  public var body: some Reducer<State, Action> {
    BindingReducer(action: \.view)

    Scope(state: \.dashboard, action: \.dashboard, child: Dashboard.init)
    Scope(state: \.history, action: \.history, child: History.init)
    Scope(state: \.statistic, action: \.statistic, child: Statistic.init)

    Reduce { state, action in
      if case let .view(action) = action {
        switch action {
        case .factButtonTapped:
          state.fact = Facts.State()
        case .infoButtonTapped:
          state.info = Info.State()
        case .transferButtonTapped:
          state.transfer = Transfer.State()
        case .binding: break
        }
      }

      return .none
    }
    .ifLet(\.$fact, action: \.fact) { Facts() }
    .ifLet(\.$info, action: \.info) { Info() }
    .ifLet(\.$transfer, action: \.transfer) { Transfer() }
  }

  public init() {}
}
