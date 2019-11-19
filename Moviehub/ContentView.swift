import SwiftUI
import Search
import ComposableArchitecture

struct ContentView: View {
  @ObservedObject var store: Store<AppState, AppAction>
  
  var body: some View {
    TabView {
      NavigationView {
        SearchView(
          store: self.store.view(
            value: { $0.search },
            action: AppAction.search
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
