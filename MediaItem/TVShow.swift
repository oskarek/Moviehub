import Foundation

public let dummyTVShow = TVShow(
  posterPath: nil,
  overview: "An exiting tv-show",
  firstAirDate: "2018-01-11",
  id: 0,
  name: "A bus",
  voteAverage: 7.2
)

public struct TVShow: Codable, Identifiable {
  public let posterPath: String?
  public let overview: String?
  public let firstAirDate: String?
  public let id: Int?
  public let name: String?
  public let voteAverage: Double?
}
