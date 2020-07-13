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
          NavigationLink(destination: Text("\(item.headline)")) {
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
  static let searchResult = [MediaItem.movie(dummyMovie), .tv(dummyTVShow), .person(dummyPerson)]

  static var previews: some View {
    let store = Store<SearchState, SearchAction>(
      initialState: .init(
        query: "",
        items: [],
        itemImageStates: [:],
        shouldShowActivityIndicator: false
      ),
      reducer: searchReducer,
      environment: .init(
        provider: .mock,
        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
      )
    )
    return NavigationView {
      SearchView(store: store)
    }
  }
}
