import Foundation

public enum ImageState: Equatable {
  case empty
  case loading
  case loaded(Data)
}
