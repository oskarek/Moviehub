import Foundation
import SwiftUI
import ComposableArchitecture
import MoviehubAPI
import MoviehubTypes
import MoviehubUtils

// MARK: Action

public enum SearchAction: Equatable {
  case textChanged(String)
  case performSearch
  case resultChanged([MediaItem]?)
  case setImageState(for: MediaItem.ID, to: LoadingState<Data>)
}

// MARK: State

public struct SearchState: Equatable {
  public var query: String
  public var items: [MediaItem]?
  public var itemImageStates: [MediaItem.ID: LoadingState<Data>]
  public var shouldShowSpinner: Bool

  public init(
    query: String,
    items: [MediaItem]?,
    itemImageStates: [MediaItem.ID: LoadingState<Data>],
    shouldShowSpinner: Bool
  ) {
    self.query = query
    self.items = items
    self.itemImageStates = itemImageStates
    self.shouldShowSpinner = shouldShowSpinner
  }
}

// MARK: Environment

public struct SearchEnvironment {
  var provider: TMDbProvider
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(provider: TMDbProvider, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.provider = provider
    self.mainQueue = mainQueue
  }
}

// MARK: Reducer

public let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment>.strict { state, action in
  struct PerformSeachId: Hashable {}
  struct MultiSearchId: Hashable {}
  struct ImageSearchId: Hashable {}

  switch action {
  case let .textChanged(query):
    state.query = query
    guard !query.isEmpty else {
      return { _ in
        .merge(
          Effect(value: .resultChanged(nil)),
          .cancel(id: PerformSeachId()),
          .cancel(id: ImageSearchId())
        )
      }
    }
    return { environment in
      Effect(value: SearchAction.performSearch)
        .debounce(
          id: PerformSeachId(),
          for: .milliseconds(300),
          scheduler: environment.mainQueue
        )
    }
  case let .resultChanged(items):
    state.shouldShowSpinner = false
    state.itemImageStates = [:]
    state.items = items
    return { environment in
      Effect.merge(items?.map { item in
        environment.provider
          .searchResultImage(item)
          .receive(on: environment.mainQueue)
          .eraseToEffect()
          .map { $0.map(LoadingState.loaded) ?? .empty }
          .map { SearchAction.setImageState(for: item.id, to: $0) }
      } ?? [])
      .cancellable(id: MultiSearchId(), cancelInFlight: true)
    }
  case let .setImageState(mediaItemId, imageState):
    state.itemImageStates[mediaItemId] = imageState
    return .none
  case .performSearch:
    state.shouldShowSpinner = state.items == nil
    let query = state.query
    return { environment in
      environment.provider
        .multiSearch(query)
        .receive(on: environment.mainQueue)
        .eraseToEffect()
        .map(SearchAction.resultChanged)
        .cancellable(id: MultiSearchId(), cancelInFlight: true)
    }
  }
}

// MARK: View

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
          )
        )
        if viewStore.shouldShowSpinner {
          VStack {
            ActivityIndicator()
              .frame(width: CGFloat(15.0), height: CGFloat(15.0))
              .padding(50)
            Spacer()
          }
        } else {
          SearchResultView(
            items: viewStore.items,
            imageStates: viewStore.itemImageStates
          )
        }
      }
      .navigationBarTitle("Search")
    }
  }
}

// MARK: Previews

struct SearchView_Previews: PreviewProvider {
  static let searchResult = Array(repeating: dummyMediaItem, count: 5)

  static var previews: some View {
    let store = Store<SearchState, SearchAction>(
      initialState: .init(
        query: "",
        items: searchResult,
        itemImageStates: [:],
        shouldShowSpinner: false
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

// TODO: move to some better place
extension Reducer {
  static func strict(
    _ reducer: @escaping (inout State, Action) -> ((Environment) -> Effect<Action, Never>)?
  ) -> Reducer {
    .init { state, action, environment in
      reducer(&state, action)?(environment) ?? .none
    }
  }
}
