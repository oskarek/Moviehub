import Foundation
import SwiftUI
import ComposableArchitecture
import Movie

public enum SearchAction {
  case textChanged(String)
  case search

  public var textChanged: String? {
    get {
      guard case let .textChanged(value) = self else { return nil }
      return value
    }
    set {
      guard case .textChanged = self, let newValue = newValue else { return }
      self = .textChanged(newValue)
    }
  }

  public var search: Void? {
    guard case .search = self else { return nil }
    return ()
  }
}

public typealias SearchState = (searchText: String, searchResult: [Movie]?)

public let searchReducer: Reducer<SearchState, SearchAction> = { state, action in
  switch action {
  case let .textChanged(searchString):
    state.searchText = searchString
    return [
    ]
  case .search:
    // TODO: search for the movie
    return [
    ]
  }
}

public struct SearchView: View {
  @State var searchText: String = ""
  @ObservedObject var store: Store<SearchState, SearchAction>
  
  public init(store: Store<SearchState, SearchAction>) {
    self.store = store
  }
  
  public var body: some View {
    VStack {
      SearchBar(
        title: "Movies, TV-shows, actors..",
        searchText: Binding(
          get: { self.store.value.searchText },
          set: { self.store.send(.textChanged($0)) }
        )
      )
      Spacer()
    }.navigationBarTitle("Search")
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    let store = Store<SearchState, SearchAction>(
      initialValue: (searchText: "", searchResult: nil),
      reducer: searchReducer
    )
    return NavigationView {
      SearchView(store: store)
    }
  }
}
