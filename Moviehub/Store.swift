import Foundation
import ComposableArchitecture
import MoviehubTypes

struct AppState {
  var searchText: String = ""
  var searchResult: [MediaItem] = []
  var searchItemImageStates: [MediaItem.ID: LoadingState<Data>] = [:]
  var searchShouldShowActivityIndicator: Bool = false
}

extension AppState {
  var search: SearchState {
    get {
      SearchState(
        query: self.searchText,
        items: self.searchResult,
        itemImageStates: self.searchItemImageStates,
        shouldShowActivityIndicator: self.searchShouldShowActivityIndicator
      )
    }
    set {
      self.searchText = newValue.query
      self.searchResult = newValue.items
      self.searchItemImageStates = newValue.itemImageStates
      self.searchShouldShowActivityIndicator = newValue.shouldShowActivityIndicator
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
