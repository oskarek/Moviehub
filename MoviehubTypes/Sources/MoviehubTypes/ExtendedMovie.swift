import Foundation

public struct ExtendedMovie: Codable, Identifiable, Equatable {
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
