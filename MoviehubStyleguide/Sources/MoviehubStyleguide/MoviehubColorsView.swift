import SwiftUI

struct MoviehubColorView: View {
  let name: String
  let color: Color
  var body: some View {
    HStack(alignment: .center, spacing: 10) {
      Circle()
        .fill()
        .frame(width: 50, height: 50)
        .foregroundColor(self.color)
      Text(self.name)
      Spacer()
    }

  }
}

struct MoviehubColorsView: View {
  var body: some View {
    List {
      MoviehubColorView(name: "emptyImage", color: MoviehubColor.emptyImage)
    }
  }
}

struct MoviehubColorsView_Previews: PreviewProvider {

  static var previews: some View {
    MoviehubColorsView().previewLayout(.sizeThatFits)
  }
}