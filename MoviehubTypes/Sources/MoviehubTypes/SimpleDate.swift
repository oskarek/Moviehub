import Foundation

/// A date type that contains year, month and day components
public struct SimpleDate {
  public let year: Int
  public let month: Int
  public let day: Int
}

public enum SimpleDateCodableError: Error {
  case incorrectFormat
}

extension SimpleDate: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    let components = string.components(separatedBy: "-")
    guard
      components.count == 3,
      let year = Int(components[0]),
      let month = Int(components[1]),
      let day = Int(components[2]),
      month >= 1 && month <= 12,
      day >= 1 && day <= 31 else { throw SimpleDateCodableError.incorrectFormat }
    self.year = year
    self.month = month
    self.day = day
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode("\(self)")
  }
}

extension SimpleDate: Equatable {}

extension SimpleDate: Comparable {
  public static func < (lhs: SimpleDate, rhs: SimpleDate) -> Bool {
    return (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
  }
}

extension SimpleDate: CustomStringConvertible {
  public var description: String {
    let monthString = "0\(self.month)".suffix(2)
    let dayString = "0\(self.day)".suffix(2)
    return "\(self.year)-\(monthString)-\(dayString)"
  }
}
