// Created by Leopold Lemmermann on 04.02.25.

import Code
import ComposableArchitecture
import struct Extensions.DataFile
import Foundation
import Storage
import Types

@Reducer
public struct Transfer {
  @ObservableState public struct State: Equatable, Sendable {
    @Shared var entries: Dates
    @Shared var encoding: Encoding
    @Presents var alert: AlertState<Action.Alert>?
    var importing = false
    var exporting = false
    var preview: String?
    var file: DataFile?

    public init(
      entries: Dates = Dates(),
      encoding: Encoding = Encoding.daily,
      alert: AlertState<Action.Alert>? = nil,
      importing: Bool = false,
      exporting: Bool = false,
      preview: String? = nil,
      file: DataFile? = nil
    ) {
      _entries = Shared(wrappedValue: entries, .fileStorage(AppGroup.containerURL.appending(path: "entries.json")))
      _encoding = Shared(wrappedValue: encoding, .appStorage("transfer_encoding"))
      self.alert = alert
      self.importing = importing
      self.exporting = exporting
      self.preview = preview
      self.file = file
    }
  }

  public enum Action: Sendable, ViewAction {
    case select(Encoding),
         updateFile(Dates),
         preview(String?), file(DataFile?),
         loadEntries, addEntries(Dates)

    case failure(String)

    case alert(PresentationAction<Alert>)
    public enum Alert: Equatable, Sendable {}

    case view(View)
    @CasePathable
    public enum View: BindableAction, Sendable {
      case binding(BindingAction<State>)

      case appear
      case importButtonTapped
      case exportButtonTapped
      case `import`(Result<URL, any Error>)
      case export(Result<URL, any Error>)
    }
  }

  public var body: some Reducer<State, Action> {
    BindingReducer(action: \.view)

    Reduce { state, action in
      switch action {
      case let .select(encoding):
        state.$encoding.withLock { $0 = encoding }
        return .send(.updateFile(state.entries))

      case let .updateFile(entries):
        return .run { [state] send in
          await send(.file(nil))

          @Dependency(\.code.encode) var encode
          let dates = DataFile(try await encode(entries.array, state.encoding))
          await send(.file(dates))
        }

      case let .file(file):
        state.file = file
        return .send(.preview(file.flatMap { String(data: $0.content, encoding: .utf8) }))

      case let .preview(preview):
        state.preview = preview

      case .loadEntries:
        if let file = state.file {
          return .run { send in
            @Dependency(\.code.decode) var decode

            for encoding in Encoding.allCases {
              do {
                let dates = Dates(try await decode(file.content, encoding))
                return await send(.addEntries(dates))
              } catch {}
            }

            await send(.failure(String(localizable: .error)))
          }
        } else {
          preconditionFailure()
        }

      case let .addEntries(entries):
        state.$entries.withLock { $0 = entries }

      case let .failure(error):
        state.alert = AlertState { TextState(error) }

      case let .view(action):
        switch action {
        case .appear:
          return .send(.updateFile(state.entries))

        case .importButtonTapped:
          state.exporting = false
          state.importing = true

        case .exportButtonTapped:
          state.importing = false
          state.exporting = true

        case let .import(result):
          do {
            return .concatenate(
              .send(.file(try DataFile(at: try result.get()))),
              .send(.loadEntries)
            )
          } catch {
            return switch error {
            case let error as URLError where error.code == .noPermissionsToReadFile:
                .send(.failure(String(localizable: .noPermission)))
            default:
                .send(.failure(String(localizable: .error)))
            }
          }

        case let .export(result):
          do {
            debugPrint(try result.get())
          } catch {
            return .send(.failure(String(localizable: .error)))
          }

        case .binding(\.$encoding):
          return .send(.select(state.encoding))

        case .binding: break
        }

      case .alert: break
      }

      return .none
    }
    .ifLet(\.$alert, action: \.alert)
    .onChange(of: \.entries) { old, new in
      Reduce { _, _ in
        old != new ? .send(.updateFile(new)) : .none
      }
    }
  }

  public init() {}
}

extension Transfer.State {
  var loadingExport: Bool { file == nil }
  var loadingImport: Bool { file == nil }
}
