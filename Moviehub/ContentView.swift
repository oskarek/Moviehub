import ComposableArchitecture
import MoviehubAPI
import SwiftUI

struct ContentView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    TabView {
      Text("On this screen, you will get a recommendation for what to watch tonight!")
        .multilineTextAlignment(.center)
        .tabItem {
          Image(systemName: "wand.and.stars")
          Text("What to watch")
        }

      Text("On this screen, all your favorites will be listed")
        .multilineTextAlignment(.center)
        .tabItem {
          Image(systemName: "star")
          Text("Favorites")
        }

      NavigationView {
        SearchView(
          store: self.store.scope(
            state: { $0.search },
            action: { .search($0) }
          )
        )
      }
      .tabItem {
        Image(systemName: "magnifyingglass")
        Text("Search")
      }

      NavigationView {
        Form {
          Section(header: Text("Dummy section 1")) {
            Toggle("Dummy toggle 1", isOn: .constant(true))
            Toggle("Dummy toggle 2", isOn: .constant(false))
          }

          Section(header: Text("Dummy section 2")) {
            Toggle("Dummy toggle 3", isOn: .constant(true))
          }
        }
        .navigationTitle("Settings")
      }
      .tabItem {
        Image(systemName: "gear")
        Text("Settings")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static let store = Store<AppState, AppAction>(
    initialState: AppState(),
    reducer: appReducer,
    environment: .mock(
      apiProvider: .mock()
    )
  )

  static var previews: some View {
    Group {
      ContentView(store: store).colorScheme(.light)
      ContentView(store: store).colorScheme(.dark)
    }
    .environment(\.locale, Locale(identifier: "sv-SE"))
  }
}
