import Foundation

/// User doc
class User {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func method() {
        print(name)
    }
}
