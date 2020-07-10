import SwiftUI
import MoviehubTypes
import MoviehubUtils

struct SearchResultRow: View {
  let imageState: LoadingState<Data>
  let mediaItem: MediaItem
  var body: some View {
    HStack {
      imageView(for: self.mediaItem, inState: self.imageState, ofSize: .init(width: 59, height: 88))
      VStack(alignment: .leading) {
        Text(mediaItem.headline)
          .font(.headline)
        Text(mediaItem.subheadline)
          .font(.caption)
      }
      Spacer()
    }
    .padding(6)
    .frame(height: 100)
    .listRowInsets(.init())
  }
}

struct SearchResultRow_Previews: PreviewProvider {
  static let items = [MediaItem.movie(dummyMovie), .tv(dummyTVShow), .person(dummyPerson)]

  static var previews: some View {
    Group {
      ForEach(items) { item in
        SearchResultRow(imageState: .empty, mediaItem: item)
          .previewLayout(.sizeThatFits)
          .previewDisplayName(item.headline)
      }
    }
  }
}
