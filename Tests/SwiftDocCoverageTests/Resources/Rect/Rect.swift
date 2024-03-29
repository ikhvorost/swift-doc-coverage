import Foundation

/// Doc line
open struct Rect {
  fileprivate let index = 0
  
  /** Doc block */
  private var origin = Point()
  
  // Comment line
  var size = Size()
  
  /* Comment block */
  public var center: Point {
    get {
      let centerX = origin.x + (size.width / 2)
      let centerY = origin.y + (size.height / 2)
      return Point(x: centerX, y: centerY)
    }
    set(newCenter) {
      origin.x = newCenter.x - (size.width / 2)
      origin.y = newCenter.y - (size.height / 2)
    }
  }
}
