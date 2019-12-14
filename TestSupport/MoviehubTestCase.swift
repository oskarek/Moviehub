import Foundation
import XCTest
import Environment

open class MoviehubTestCase: XCTestCase {
  public override class func setUp() {
    Current = .mock
  }
}
