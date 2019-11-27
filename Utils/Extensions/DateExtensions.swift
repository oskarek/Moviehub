import Foundation

extension Date {
  // Zero out the seconds of the Date
  public var zeroSeconds: Date {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
    return calendar.date(from: dateComponents)!
  }
}
