import Foundation
import Combine
import MoviehubTypes
import ComposableArchitecture
import MoviehubUtils
import UIKit

// MARK: TMDbProvider
public struct TMDbProvider {
  /// Hit the multi-search api endpoint. Returns a list of MediaItems, that matches the search query.
  /// - Parameter query: The string to search for.
  public var multiSearch: (_ query: String) -> Effect<[MediaItem]?, Never>
  /// Fetch an image for a mediaItem to display in the search results.
  public var searchResultImage: (_ mediaItem: MediaItem) -> Effect<UIImage?, Never>
  /// Get extended information about a movie, via its id
  public var movie: (_ movieId: Movie.ID) -> Effect<Movie?, Never>

  public init(
    multiSearch: @escaping (_ query: String) -> Effect<[MediaItem]?, Never>,
    searchResultImage: @escaping (_ mediaItem: MediaItem) -> Effect<UIImage?, Never>,
    movie: @escaping (_ movieId: Movie.ID) -> Effect<Movie?, Never>) {
    self.multiSearch = multiSearch
    self.searchResultImage = searchResultImage
    self.movie = movie
  }
}

// MARK: Live implementation of TMDbProvider

private func imagePath(for mediaItem: MediaItem) -> String? {
  switch mediaItem {
  case let .movie(movie):
    return movie.posterPath.map { "/w92" + $0 }
  case let .tvShow(tvShow):
    return tvShow.posterPath.map { "/w92" + $0 }
  case let .person(person):
    return person.profilePath.map { "/w185" + $0 }
  }
}

private let dispatcher = TMDbDispatcher(useSampleData: false)

extension TMDbProvider {
  public static var live: TMDbProvider {
    .init(
      multiSearch: { query in
        dispatcher.dispatch(request: .multiSearch(query: query))
      },
      searchResultImage: { mediaItem in
        guard let path = imagePath(for: mediaItem) else { return .init(value: nil) }
        return dispatcher.dispatch(request: .searchResultImage(imagePath: path))
      },
      movie: { movieId in
        dispatcher.dispatch(request: .movie(id: movieId))
      }
    )
  }
}

// MARK: Mock

private let mockDataSource: [MediaItem] = [.dummyMovieItem, .dummyTVShowItem, .dummyPersonItem]

extension TMDbProvider {
  public static func mock(
    delay: DispatchQueue.SchedulerTimeType.Stride = .zero
  ) -> TMDbProvider {
    TMDbProvider(
      multiSearch: { query in
        return Effect(value: mockDataSource.filter { "\($0)".lowercased().contains(query.lowercased()) })
          .delay(for: delay, scheduler: DispatchQueue.main)
          .eraseToEffect()
      },
      searchResultImage: { _ in .init(value: nil) },
      movie: { _ in .init(value: nil) }
    )
  }
}
