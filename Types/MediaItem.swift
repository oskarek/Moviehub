import Foundation

public let dummyMediaItem = MediaItem.movie(dummyMovie)

public enum MediaItem: Equatable {
  case movie(Movie)
  case tv(TVShow)
  case person(Person)
}

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
      self = .tv(try TVShow(from: decoder))
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
    case let .tv(tvShow):
      try container.encode(MediaType.tv, forKey: .mediaType)
      try tvShow.encode(to: encoder)
    case let .person(person):
      try container.encode(MediaType.person, forKey: .mediaType)
      try person.encode(to: encoder)
    }
  }
}

extension MediaItem: Identifiable {
  public var id: Int {
    switch self {
    case let .movie(movie):
      return movie.id
    case let .tv(tv):
      return tv.id
    case let .person(person):
      return person.id
    }
  }
}