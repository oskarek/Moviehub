import Foundation
import SwiftUI
import ComposableArchitecture
import Types
import API
import Environment
import Utils

public enum SearchAction {
  case textChanged(String)
  case resultChanged([MediaItem]?)
  case setImageState(for: MediaItem, to: ImageState)

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

  public var resultChanged: [MediaItem]? {
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

public typealias SearchState = (
  query: String,
  items: [MediaItem]?,
  itemImageStates: [MediaItem.ID: ImageState],
  isLoading: Bool
)

public let searchReducer: Reducer<SearchState, SearchAction> = { state, action in
  switch action {
  case let .textChanged(query):
    state.isLoading = true
    state.query = query
    return [
      Current.apiProvider
        .multiSearch(query: state.query)
        .map(SearchAction.resultChanged)
        .receive(on: DispatchQueue.main)
        .eraseToEffect()
    ]
  case let .resultChanged(items):
    state.isLoading = false
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
          get: { self.store.value.query },
          set: { self.store.send(.textChanged($0)) }
        )
      )
      if self.store.value.isLoading && self.store.value.items == nil {
        VStack {
          ActivityIndicator()
            .frame(width: 15, height: 15, alignment: .center)
            .padding(50)
          Spacer()
        }
      } else {
        self.store.value.items.map { items in
          AnyView(List {
            ForEach(items) { item in
              SearchResultCell(
                imageState: self.store.value.itemImageStates[item.id] ?? .loading,
                mediaItem: item
              )
            }
          })
        } ?? AnyView(Spacer())
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
        isLoading: false
      ),
      reducer: searchReducer
    )
    return NavigationView {
      SearchView(store: store)
    }
  }
}
