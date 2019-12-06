import Foundation
import ComposableArchitecture
import Types
import Search

struct AppState {
  var searchText: String = ""
  var searchResult: [MediaItem]?
  var searchItemImageStates: [MediaItem.ID: ImageState] = [:]
  var isSearching: Bool = false
}

extension AppState {
  var search: SearchState {
    get {
      SearchState(
        query: self.searchText,
        items: self.searchResult,
        itemImageStates: self.searchItemImageStates,
        isLoading: self.isSearching
      )
    }
    set {
      ( self.searchText,
        self.searchResult,
        self.searchItemImageStates,
        self.isSearching ) = newValue
    }
  }
}

enum AppAction {
  case search(SearchAction)

  var search: SearchAction? {
    get {
      guard case let .search(value) = self else { return nil }
      return value
    }
    set {
      guard case .search = self, let newValue = newValue else { return }
      self = .search(newValue)
    }
  }
}

let appReducer: Reducer<AppState, AppAction> =
  pullback(searchReducer, value: \.search, action: \.search)

let store = Store<AppState, AppAction>(
  initialValue: .init(),
  reducer: appReducer
)
