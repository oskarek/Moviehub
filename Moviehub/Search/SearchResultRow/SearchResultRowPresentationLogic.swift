import Foundation
import SwiftUI
import MoviehubTypes
import MoviehubUtils
import MoviehubStyleguide

extension MediaItem {
  var headline: String {
    switch self {
    case let .movie(movie):
      return "\(movie.title) (\(movie.releaseDate.year))"
    case let .tv(tvShow):
      return "\(tvShow.name) (\(tvShow.firstAirDate.year))"
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
      return person.knownFor.map { $0.headline }.joined(separator: ", ")
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
func imageView(inState state: LoadingState<Data>, ofSize size: CGSize) -> some View {
  switch state {
  case .empty:
    return clipped(emptyImage, to: size)
  case .loading:
    let stack = ZStack(alignment: .center) {
      emptyImage
      ProgressView()
        .foregroundColor(.primary)
        .frame(width: 15, height: 15)
    }
    return clipped(stack, to: size)
  case let .loaded(data):
    let image = Image(uiImage: UIImage(data: data)!).resizable()
    return clipped(image, to: size)
  }
}
