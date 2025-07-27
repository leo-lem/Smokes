// Created by Leopold Lemmermann on 26.04.23.

import typealias ComposableArchitecture.StoreOf
import Extensions
import SwiftUI
import SwiftUIExtensions

public struct InfoView: View {
  public let store: StoreOf<Info>

  public var body: some View {
    VStack {
      Text(Bundle.main[string: "CFBundleDisplayName"])
        .font(.largeTitle)
        .lineLimit(1)
        .bold()
        .padding()

      Text(.localizable(.description), bundle: .module)
        .multilineTextAlignment(.center)

    Spacer()
      Divider()

      Section(.localizable(.links)) {
        List {
          Button(.localizable(.webpage), systemImage: "safari") {
            store.send(.openMarketing)
          }
          .labelStyle(.external(color: .green, transfer: true))
          .listRowBackground(Color.clear)

          Button(.localizable(.support), systemImage: "questionmark.circle") {
            store.send(.openSupport)
          }
          .labelStyle(.external(color: .red, transfer: true))
          .listRowBackground(Color.clear)

          Button(.localizable(.privacy), systemImage: "person.badge.key") {
            store.send(.openPrivacy)
          }
          .labelStyle(.external(color: .gray, transfer: true))
          .listRowBackground(Color.clear)
        }
        .bold()
        .listStyle(.plain)
        .buttonStyle(.borderless)
        .scrollDisabled(true)
      }

      Divider()

      Section(.localizable(.credits)) {
        VStack {
          Text(.localizable(.developed(Bundle.main[string: "Creator"])))
          Text(.localizable(.designed(Bundle.main[string: "Creator"])))
        }
        .font(.caption)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .presentationDetents([.medium])
    .presentationBackground(.ultraThinMaterial)
  }

  public init(store: StoreOf<Info>) { self.store = store }
}

#Preview {
  @Previewable @State var isPresented = false

  Toggle("Is presented", isOn: $isPresented)
    .sheet(isPresented: $isPresented) {
      InfoView(store: StoreOf<Info>(initialState: Info.State(), reducer: Info.init))
    }
}
