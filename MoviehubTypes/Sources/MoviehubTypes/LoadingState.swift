import Foundation

public enum LoadingState<Content> {
  case empty
  case loading
  case loaded(Content)
}

extension LoadingState: Equatable where Content: Equatable {}
