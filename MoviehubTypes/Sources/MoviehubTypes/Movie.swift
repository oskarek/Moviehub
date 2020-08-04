import Foundation

public struct Movie: Codable, Identifiable, Equatable {
  public let backdropPath: String?
  public let posterPath: String?
  public let overview: String?
  public let releaseDate: SimpleDate
  public let id: Int
  public let title: String
  public let originalTitle: String
  public let tagline: String?
  public let voteAverage: Double?
  public let budget: Int
  public let runtime: Int?

  public init(
    backdropPath: String?,
    posterPath: String?,
    overview: String?,
    releaseDate: SimpleDate,
    id: Int,
    title: String,
    originalTitle: String,
    tagline: String?,
    voteAverage: Double?,
    budget: Int,
    runtime: Int?
  ) {
    self.backdropPath = backdropPath
    self.posterPath = posterPath
    self.overview = overview
    self.releaseDate = releaseDate
    self.id = id
    self.title = title
    self.originalTitle = originalTitle
    self.tagline = tagline
    self.voteAverage = voteAverage
    self.budget = budget
    self.runtime = runtime
  }
}

extension Movie {
  public static var dummy: Movie {
    .init(
      backdropPath: nil,
      posterPath: nil,
      overview: "A nice movie about a car",
      releaseDate: SimpleDate(year: 1993, month: 3, day: 11),
      id: 0,
      title: "Car movie",
      originalTitle: "Car movie",
      tagline: "He may only be a car, but he's guaranteed to go far.",
      voteAverage: 9.0,
      budget: 10_000_000,
      runtime: 133
    )
  }
}
