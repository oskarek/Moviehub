import ComposableArchitecture
import Foundation
import MoviehubTypes
import SwiftUI

public struct SearchView: View {
  let store: Store<SearchState, SearchAction>

  public init(store: Store<SearchState, SearchAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        SearchBar(
          title: "Movies, TV-shows, actors..",
          searchText: viewStore.binding(
            get: { $0.query },
            send: { .textChanged($0) }
          ),
          isSearching: viewStore.shouldShowActivityIndicator
        )

        List(viewStore.items) { item in
          NavigationLink(destination: Text(String(describing: item))) {
            SearchResultRow(
              imageState: viewStore.itemImageStates[item.id] ?? .loading,
              mediaItem: item
            )
          }
        }
        .listStyle(PlainListStyle())
        .animation(.default)
      }
      .navigationBarTitle("Search")
    }
  }
}

// MARK: Previews

struct SearchView_Previews: PreviewProvider {
  static let searchResult = [MediaItem.dummyMovieItem, .dummyTVShowItem, .dummyPersonItem]

  static var previews: some View {
    let store = Store<SearchState, SearchAction>(
      initialState: SearchState(),
      reducer: searchReducer,
      environment: .init(
        provider: .mock(),
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
      )
    )
    return NavigationView {
      SearchView(store: store)
    }
    .environment(\.locale, Locale(identifier: "sv_SE"))
  }
}
