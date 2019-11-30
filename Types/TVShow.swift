import Foundation

public let dummyTVShow = TVShow(
  posterPath: nil,
  overview: "An exiting tv-show",
  firstAirDate: Date(timeIntervalSince1970: 800000000),
  id: 1,
  name: "A bus",
  voteAverage: 7.2
)

public struct TVShow: Codable, Identifiable, Equatable {
  public let posterPath: String?
  public let overview: String?
  public let firstAirDate: Date
  public let id: Int
  public let name: String
  public let voteAverage: Double?

  public init(
    posterPath: String?,
    overview: String?,
    firstAirDate: Date,
    id: Int,
    name: String,
    voteAverage: Double?
  ) {
    self.posterPath = posterPath
    self.overview = overview
    self.firstAirDate = firstAirDate.zeroSeconds
    self.id = id
    self.name = name
    self.voteAverage = voteAverage
  }
}
