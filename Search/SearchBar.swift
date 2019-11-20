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
        .disableAutocorrection(true)
      if !searchText.isEmpty {
        Button(action: { self.searchText = "" }) {
          Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
        }
      }
    }
    .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
    .background(Color.gray.opacity(0.2))
    .cornerRadius(10)
    .padding(.horizontal)
  }
}

struct SearchBar_Previews: PreviewProvider {
  static var previews: some View {
    let layout = PreviewLayout.fixed(width: 400, height: 65)
    return SearchBar(title: "Search", searchText: .constant(""))
      .previewLayout(layout)
  }
}
