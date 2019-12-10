import Foundation
import Overture
import Types
import API
import Environment
import SwiftUI
import Utils
import Styleguide

extension MediaItem {
  var headline: String {
    switch self {
    case let .movie(movie):
      let title = movie.title
      let year = "\(Current.calendar.component(.year, from: movie.releaseDate))"
      return "\(title) (\(year))"
    case let .tv(tvShow):
      let name = tvShow.name
      let year = "\(Current.calendar.component(.year, from: tvShow.firstAirDate))"
      return "\(name) (\(year))"
    case let .person(person):
      return person.name
    }
  }

  var subheadline: String {
    switch self {
    case let .movie(movie):
      return movie.overview ?? ""
    case let .tv(tvShow):
      return tvShow.overview ?? ""
    case let .person(person):
      guard let knownFor = person.knownFor else {
        return "Not known for anything. A loser."
      }

      let knownForString = knownFor.map(get(\.headline)).joined(separator: ", ")
      return "Known for: \(knownForString)"
    }
  }
}

private let emptyImage: some View =
  Rectangle().fill().foregroundColor(MoviehubColor.emptyImage)

private func clipped<V: View>(_ view: V, to size: CGSize) -> AnyView {
  return AnyView(view
    .scaledToFill()
    .frame(width: size.width, height: size.height)
    .clipped())
}

// Get the image view to be displayed for a mediaItem in the specified state
func imageView(for: MediaItem, inState state: ImageState, ofSize size: CGSize) -> some View {
  switch state {
  case .empty:
    return clipped(emptyImage, to: size)
  case .loading:
    let stack = ZStack(alignment: .center) {
      emptyImage

      ActivityIndicator()
        .foregroundColor(.primary)
        .frame(width: 15, height: 15)
    }
    return clipped(stack, to: size)
  case let .loaded(data):
    let image = Image(uiImage: UIImage(data: data)!).resizable()
    return clipped(image, to: size)
  }
}