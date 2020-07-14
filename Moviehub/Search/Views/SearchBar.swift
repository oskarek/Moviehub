import SwiftUI

struct ActivityBackgroundModifier<Background: View>: ViewModifier {
  let background: Background
  let isActive: Bool
  @State private var animationEndPosition: Bool = false

  var animation: Animation {
    Animation.easeOut(duration: 1)
      .repeatForever(autoreverses: false)
  }

  func body(content: Content) -> some View {
    content.background(
      GeometryReader { (proxy: GeometryProxy) in
        ZStack(alignment: .bottomLeading) {
          background.frame(height: proxy.size.height)
          if isActive {
            Color.blue
              .opacity(0.5)
              .frame(width: 50, height: 2)
              .cornerRadius(1)
              .offset(x: animationEndPosition ? proxy.size.width : 0)
              .onAppear {
                withAnimation(animation) {
                  animationEndPosition = true
                }
              }
              .onDisappear { animationEndPosition = false }
          }
        }
      }
    )
  }
}

extension View {
  func activityBackground<Background: View>(
    background: Background,
    isActive: Bool
  ) -> some View {
    self.modifier(
      ActivityBackgroundModifier(
        background: background,
        isActive: isActive
      )
    )
  }
}

public struct SearchBar: View {
  let title: LocalizedStringKey
  @Binding var searchText: String
  let isSearching: Bool

  public init(title: LocalizedStringKey, searchText: Binding<String>, isSearching: Bool = false) {
    self.title = title
    self._searchText = searchText
    self.isSearching = isSearching
  }

  public var body: some View {
    HStack {
      Image(systemName: "magnifyingglass").foregroundColor(.secondary)
      TextField(self.title, text: $searchText)
        .disableAutocorrection(true)
      if !searchText.isEmpty {
        Button(
          action: { self.searchText = "" },
          label: { Image(systemName: "xmark.circle.fill").foregroundColor(.secondary) }
        )
      }
    }
    .padding(8)
    .activityBackground(background: Color.gray.opacity(0.2), isActive: isSearching)
    .cornerRadius(10)
    .padding()
    .frame(height: 80)
  }
}

struct SearchBar_Previews: PreviewProvider {
  static var previews: some View {
    return SearchBar(
      title: "Search",
      searchText: .constant(""),
      isSearching: true
    )
    .previewLayout(.sizeThatFits)
  }
}
