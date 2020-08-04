import Foundation

public struct TVShow: Codable, Identifiable, Equatable {
  public let backdropPath: String?
  public let posterPath: String?
  public let overview: String?
  public let firstAirDate: SimpleDate
  public let lastAirDate: SimpleDate
  public let id: Int
  public let name: String
  public let originalName: String
  public let voteAverage: Double?

  public init(
    backdropPath: String?,
    posterPath: String?,
    overview: String?,
    firstAirDate: SimpleDate,
    lastAirDate: SimpleDate,
    id: Int,
    name: String,
    originalName: String,
    voteAverage: Double?
  ) {
    self.backdropPath = backdropPath
    self.posterPath = posterPath
    self.overview = overview
    self.firstAirDate = firstAirDate
    self.lastAirDate = lastAirDate
    self.id = id
    self.name = name
    self.originalName = originalName
    self.voteAverage = voteAverage
  }
}

extension TVShow {
  public static var dummy: TVShow {
    .init(
      backdropPath: nil,
      posterPath: nil,
      overview: "An exiting tv-show",
      firstAirDate: SimpleDate(year: 1985, month: 8, day: 21),
      lastAirDate: SimpleDate(year: 2004, month: 1, day: 22),
      id: 1,
      name: "A bus",
      originalName: "A bus",
      voteAverage: 7.2
    )
  }
}
