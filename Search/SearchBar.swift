import SwiftUI

public struct SearchBar : View {
  let title: String
  @Binding var searchText: String
  
  public init(title: String, searchText: Binding<String>) {
    self.title = title
    self._searchText = searchText
  }
  
  public var body: some View {
    HStack {
      Image(systemName: "magnifyingglass").foregroundColor(.secondary)
      TextField(self.title, text: $searchText)
      if !searchText.isEmpty {
        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
      }
    }.padding(.horizontal)
  }
}

struct SearchBar_Previews: PreviewProvider {
  static var previews: some View {
    let layout = PreviewLayout.fixed(width: 400, height: 50)
    return SearchBar(title: "Search", searchText: .constant(""))
      .previewLayout(layout)
  }
}
