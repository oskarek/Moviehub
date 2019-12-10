import Foundation
import SwiftUI
import ComposableArchitecture
import Types
import API
import Environment
import Utils

public enum SearchAction: Equatable {
  case textChanged(String)
  case resultChanged([MediaItem]?)
  case setImageState(for: MediaItem, to: ImageState)
}

public struct SearchState: Equatable {
  public var query: String
  public var items: [MediaItem]?
  public var itemImageStates: [MediaItem.ID: ImageState]
  public var shouldShowSpinner: Bool

  public init(
    query: String,
    items: [MediaItem]?,
    itemImageStates: [MediaItem.ID: ImageState],
    shouldShowSpinner: Bool
  ) {
    self.query = query
    self.items = items
    self.itemImageStates = itemImageStates
    self.shouldShowSpinner = shouldShowSpinner
  }
}

public let searchReducer: Reducer<SearchState, SearchAction> = { state, action in
  switch action {
  case let .textChanged(query):
    state.shouldShowSpinner = state.items == nil
    state.query = query
    return [
      Current.apiProvider
        .multiSearch(query: state.query)
        .map(SearchAction.resultChanged)
        .receive(on: DispatchQueue.main)
        .eraseToEffect()
    ]
  case let .resultChanged(items):
    state.shouldShowSpinner = false
    state.itemImageStates = [:]
    state.items = items
    return items?.map { item in
      Current.apiProvider
        .searchResultImage(for: item)
        .map { data in
          let state = data.map(ImageState.loaded) ?? .empty
          return SearchAction.setImageState(for: item, to: state)
        }
        .receive(on: DispatchQueue.main)
        .eraseToEffect()
    } ?? []
  case let .setImageState(mediaItem, imageState):
    state.itemImageStates[mediaItem.id] = imageState
    return []
  }
}

public struct SearchView: View {
  @ObservedObject var store: Store<SearchState, SearchAction>

  public init(store: Store<SearchState, SearchAction>) {
    self.store = store
  }

  public var body: some View {
    VStack {
      SearchBar(
        title: "Movies, TV-shows, actors..",
        searchText: Binding(
          get: { self.store.value.query },
          set: { self.store.send(.textChanged($0)) }
        )
      )
      if self.store.value.shouldShowSpinner {
        VStack {
          ActivityIndicator()
            .frame(width: 15, height: 15)
            .padding(50)
          Spacer()
        }
      } else {
        SearchResultView(
          items: self.store.value.items,
          imageStates: self.store.value.itemImageStates
        )
      }
    }.navigationBarTitle("Search")
  }
}

struct SearchView_Previews: PreviewProvider {
  static let searchResult = Array(repeating: dummyMediaItem, count: 5)

  static var previews: some View {
    let store = Store<SearchState, SearchAction>(
      initialValue: SearchState(
        query: "",
        items: searchResult,
        itemImageStates: [:],
        shouldShowSpinner: false
      ),
      reducer: searchReducer
    )
    return NavigationView {
      SearchView(store: store)
    }
  }
}
