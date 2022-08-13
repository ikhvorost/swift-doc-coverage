import Foundation


typealias SSN = Int

prefix operator +++

enum CompassPoint {
    case north
    case south
    case east
    case west
}

#if DEBUG
protocol Container1 {
    associatedtype Item
    mutating func append(_ item: Item)
}
#else
protocol Container2 {
    associatedtype Item2
    public static mutating func append(_ item: Item2)
}
#endif


/// User doc
class User {
    let name: String
    let ssn: SSN
    
    subscript(index: Int) -> Int {
        get {
            return 1
        }
        set(newValue) {
            // Perform a suitable setting action here.
        }
    }
    
    public init(name: String, ssn: SSN) {
        self.name = name
        self.ssn = Age
    }
    
    func method() {
        print(name)
    }
}

extension User: CustomStringConvertible {
    var description: String {
        return ""
    }
}
