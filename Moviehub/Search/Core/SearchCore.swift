import ComposableArchitecture
import Foundation
import MoviehubAPI
import MoviehubTypes
import UIKit

// MARK: State

public struct SearchState: Equatable {
  public var query: String
  public var items: [MediaItem]
  public var itemImageStates: [MediaItem.ID: LoadingState<UIImage>]
  public var shouldShowActivityIndicator: Bool

  public init(
    query: String = "",
    items: [MediaItem] = [],
    itemImageStates: [MediaItem.ID: LoadingState<UIImage>] = [:],
    shouldShowActivityIndicator: Bool = false
  ) {
    self.query = query
    self.items = items
    self.itemImageStates = itemImageStates
    self.shouldShowActivityIndicator = shouldShowActivityIndicator
  }
}

// MARK: Action

public enum SearchAction: Equatable {
  case textChanged(String)
  case performSearch
  case resultChanged([MediaItem]?)
  case setImageState(for: MediaItem.ID, to: LoadingState<UIImage>)
  case showActivityIndicator
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

public let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment> { state, action, environment in
  struct PerformSeachId: Hashable {}
  struct MultiSearchId: Hashable {}
  struct ImageSearchId: Hashable {}
  struct SearchActiveId: Hashable {}

  switch action {
  case let .textChanged(query):
    state.query = query
    guard !query.isEmpty else {
      return .merge(
        Effect(value: .resultChanged(nil)),
        .cancel(id: PerformSeachId()),
        .cancel(id: MultiSearchId()),
        .cancel(id: ImageSearchId())
      )
    }
    return Effect(value: SearchAction.performSearch)
      .debounce(
        id: PerformSeachId(),
        for: .milliseconds(300),
        scheduler: environment.mainQueue
      )
  case let .resultChanged(items):
    state.shouldShowActivityIndicator = false
    if items == nil { state.itemImageStates = [:] }
    state.items = items ?? []

    return Effect.merge(items?.map { item in
      environment.provider
        .searchResultImage(item)
        .receive(on: environment.mainQueue)
        .eraseToEffect()
        .map { $0.map(LoadingState.loaded) ?? .empty }
        .map { SearchAction.setImageState(for: item.id, to: $0) }
    } ?? [])
    .cancellable(id: ImageSearchId(), cancelInFlight: true)
  case let .setImageState(mediaItemId, imageState):
    state.itemImageStates[mediaItemId] = imageState
    return .none
  case .performSearch:
    let query = state.query

    let activateSearchEffect = Effect<SearchAction, Never>(value: .showActivityIndicator)
      .delay(for: .milliseconds(300), scheduler: environment.mainQueue)
      .eraseToEffect()
      .cancellable(id: SearchActiveId(), cancelInFlight: true)
    let multiSearchEffect = Effect.concatenate(
      environment.provider
        .multiSearch(query)
        .receive(on: environment.mainQueue)
        .eraseToEffect()
        .map(SearchAction.resultChanged)
        .cancellable(id: MultiSearchId(), cancelInFlight: true),
      .cancel(id: SearchActiveId())
    )
    return .merge(activateSearchEffect, multiSearchEffect)
  case .showActivityIndicator:
    state.shouldShowActivityIndicator = true
    return .none
  }
}
