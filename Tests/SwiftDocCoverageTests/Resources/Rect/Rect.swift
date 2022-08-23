import Foundation

/// Doc line
public struct Rect {
    /** Doc block */
    public var origin = Point()
    
    // Line
    public var size = Size()
    
    /* Block */
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
