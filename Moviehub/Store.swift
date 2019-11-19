import Foundation
import ComposableArchitecture
import Movie
import Search

struct AppState {
  var searchText: String = ""
  var searchResult: [Movie]? = nil
}

extension AppState {
  var search: SearchState {
    get {
      (searchText: self.searchText, searchResult: self.searchResult)
    }
    set {
      (self.searchText, self.searchResult) = newValue
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
