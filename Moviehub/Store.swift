import Foundation
import ComposableArchitecture
import MoviehubTypes
import MoviehubSearch

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
  var search: SearchEnvironment { .init(provider: self.apiProvider, mainQueue: self.mainQueue) }
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> =
  searchReducer.pullback(state: \.search, action: /AppAction.search, environment: \.search)

let store = Store<AppState, AppAction>(
  initialState: .init(),
  reducer: appReducer,
  environment: .live
)
