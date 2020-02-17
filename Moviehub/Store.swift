import Foundation
import ComposableArchitecture
import Types
import Search
import CasePaths

struct AppState {
  var searchText: String = ""
  var searchResult: [MediaItem]?
  var searchItemImageStates: [MediaItem.ID: LoadingState<Data>] = [:]
  var shouldShowSearchSpinner: Bool = false
}

extension AppState {
  var search: SearchState {
    get {
      SearchState(
        query: self.searchText,
        items: self.searchResult,
        itemImageStates: self.searchItemImageStates,
        shouldShowSpinner: self.shouldShowSearchSpinner
      )
    }
    set {
      self.searchText = newValue.query
      self.searchResult = newValue.items
      self.searchItemImageStates = newValue.itemImageStates
      self.shouldShowSearchSpinner = newValue.shouldShowSpinner
    }
  }
}

enum AppAction {
  case search(SearchAction)
}

extension AppEnvironment {
  var search: SearchEnvironment { self.apiProvider }
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> =
  searchReducer.pullback(value: \.search, action: /AppAction.search, environment: \.search)

let store = Store<AppState, AppAction>(
  initialValue: .init(),
  reducer: appReducer,
  environment: .live
)
