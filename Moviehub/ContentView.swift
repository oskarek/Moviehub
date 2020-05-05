import SwiftUI
import MoviehubSearch
import ComposableArchitecture

struct ContentView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    TabView {
      NavigationView {
        SearchView(
          store: self.store.scope(
            state: { $0.search },
            action: { .search($0) }
          )
        )
      }
        .tabItem {
          Image(systemName: "1.square.fill")
          Text("Search")
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView(store: store).colorScheme(.light)
      ContentView(store: store).colorScheme(.dark)
    }
  }
}
