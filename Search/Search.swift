import Foundation
import SwiftUI
import ComposableArchitecture
import MediaItem
import API

public enum SearchAction {
  case textChanged(String)
  case resultChanged([MediaItem]?)

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

  public var resultChanged: [MediaItem]?? {
    get {
      guard case let .resultChanged(value) = self else { return nil }
      return value
    }
    set {
      guard case .resultChanged = self, let newValue = newValue else { return }
      self = .resultChanged(newValue)
    }
  }
}

public typealias SearchState = (searchText: String, searchResult: [MediaItem]?)

public let searchReducer: Reducer<SearchState, SearchAction> = { state, action in
  switch action {
  case let .textChanged(searchString):
    state.searchText = searchString
    return [
      multiSearch(query: state.searchText)
        .map(SearchAction.resultChanged)
        .receive(on: DispatchQueue.main)
        .eraseToEffect()
    ]
  case let .resultChanged(items):
    state.searchResult = items
    return []
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
      self.store.value.searchResult.map { items in
        AnyView(List(items, rowContent: SearchResultCell.init))
      } ?? AnyView(Spacer())
    }.navigationBarTitle("Search")
  }
}

struct SearchView_Previews: PreviewProvider {
  static let searchResult = [dummyMediaItem]

  static var previews: some View {
    let store = Store<SearchState, SearchAction>(
      initialValue: (searchText: "", searchResult: searchResult),
      reducer: searchReducer
    )
    return NavigationView {
      SearchView(store: store)
    }
  }
}
