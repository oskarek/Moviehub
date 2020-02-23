import SwiftUI
import MoviehubTypes

struct SearchResultView: View {
  let items: [MediaItem]?
  let imageStates: [MediaItem.ID: LoadingState<Data>]
  var body: some View {
    self.items.map { items in
      AnyView(List {
        ForEach(items) { item in
          SearchResultRow(
            imageState: self.imageStates[item.id] ?? .loading,
            mediaItem: item
          )
        }
      })
    } ?? AnyView(Spacer())
  }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
      SearchResultView(
        items: [.movie(dummyMovie), .tv(dummyTVShow), .person(dummyPerson)],
        imageStates: [:]
      ).previewLayout(.sizeThatFits)
    }
}