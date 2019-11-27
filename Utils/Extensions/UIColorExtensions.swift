import UIKit

extension UIColor {
  // Create an image of the given size, filled with this color
  public func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
      return UIGraphicsImageRenderer(size: size).image { rendererContext in
          self.setFill()
          rendererContext.fill(CGRect(origin: .zero, size: size))
      }
  }
}
