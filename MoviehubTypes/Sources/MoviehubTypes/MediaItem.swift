import Foundation

public enum MediaItem: Equatable {
  case movie(Movie)
  case tvShow(TVShow)
  case person(Person)
}

// MARK: Movie

extension MediaItem {
  public struct Movie: Codable, Identifiable, Equatable {
    public let posterPath: String?
    public let overview: String?
    public let releaseDate: SimpleDate
    public let id: Int
    public let title: String
    public let voteAverage: Double?

    public init(
      posterPath: String?,
      overview: String?,
      releaseDate: SimpleDate,
      id: Int,
      title: String,
      voteAverage: Double?
    ) {
      self.posterPath = posterPath
      self.overview = overview
      self.releaseDate = releaseDate
      self.id = id
      self.title = title
      self.voteAverage = voteAverage
    }
  }

  public static var dummyMovieItem: MediaItem {
    .movie(.init(
      posterPath: nil,
      overview: "A nice movie about a car",
      releaseDate: SimpleDate(year: 1993, month: 3, day: 11),
      id: 0,
      title: "Car movie",
      voteAverage: 9.0
    ))
  }
}

// MARK: TVShow

extension MediaItem {
  public struct TVShow: Codable, Identifiable, Equatable {
    public let posterPath: String?
    public let overview: String?
    public let firstAirDate: SimpleDate
    public let id: Int
    public let name: String
    public let voteAverage: Double?

    public init(
      posterPath: String?,
      overview: String?,
      firstAirDate: SimpleDate,
      id: Int,
      name: String,
      voteAverage: Double?
    ) {
      self.posterPath = posterPath
      self.overview = overview
      self.firstAirDate = firstAirDate
      self.id = id
      self.name = name
      self.voteAverage = voteAverage
    }
  }

  public static var dummyTVShowItem: MediaItem {
    .tvShow(.init(
      posterPath: nil,
      overview: "An exiting tv-show",
      firstAirDate: SimpleDate(year: 1985, month: 8, day: 21),
      id: 1,
      name: "A bus",
      voteAverage: 7.2
    ))
  }
}

// MARK: Person

extension MediaItem {
  public struct Person: Codable, Identifiable, Equatable {
    public let profilePath: String?
    public let id: Int
    public let knownFor: [MediaItem]
    public let name: String

    public init(
      profilePath: String?,
      id: Int,
      knownFor: [MediaItem],
      name: String
    ) {
      self.profilePath = profilePath
      self.id = id
      self.knownFor = knownFor
      self.name = name
    }
  }

  public static var dummyPersonItem: MediaItem {
    .person(.init(
      profilePath: nil,
      id: 2,
      knownFor: [.dummyMovieItem, .dummyTVShowItem],
      name: "Oskar Ek"
    ))
  }
}

// MARK: Codable conformance

extension MediaItem: Codable {
  private enum CodingKeys: String, CodingKey {
    case mediaType
  }

  private enum MediaType: String, Codable {
    case movie
    case tv
    case person
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let value = try container.decode(MediaType.self, forKey: .mediaType)
    switch value {
    case .movie:
      self = .movie(try Movie(from: decoder))
    case .tv:
      self = .tvShow(try TVShow(from: decoder))
    case .person:
      self = .person(try Person(from: decoder))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case let .movie(movie):
      try container.encode(MediaType.movie, forKey: .mediaType)
      try movie.encode(to: encoder)
    case let .tvShow(tvShow):
      try container.encode(MediaType.tv, forKey: .mediaType)
      try tvShow.encode(to: encoder)
    case let .person(person):
      try container.encode(MediaType.person, forKey: .mediaType)
      try person.encode(to: encoder)
    }
  }
}

// MARK: Identifiable conformance

extension MediaItem: Identifiable {
  public var id: Int {
    switch self {
    case let .movie(movie):
      return movie.id
    case let .tvShow(tv):
      return tv.id
    case let .person(person):
      return person.id
    }
  }
}

// MARK: Convenience properties

extension MediaItem {
  public var imagePath: String? {
    switch self {
    case let .movie(movie): return movie.posterPath
    case let .tvShow(tvShow): return tvShow.posterPath
    case let .person(person): return person.profilePath
    }
  }
}

extension MediaItem: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .movie(movie):
      return "\(movie.title) (\(movie.releaseDate.year))"
    case let .tvShow(tvShow):
      return "\(tvShow.name) (\(tvShow.firstAirDate.year))"
    case let .person(person):
      return person.name
    }
  }
}
