import Foundation

public struct MediaItem: Codable {
  public enum MediaType: String, Codable {
    case movie
    case tv
    case person
  }

  public let mediaType: MediaType
  public let id: Int?
  public let title: String?
  public let posterPath: String?

  public init(mediaType: MediaType, id: Int?, title: String?, posterPath: String?) {
    self.mediaType = mediaType
    self.id = id
    self.title = title
    self.posterPath = posterPath
  }
}
