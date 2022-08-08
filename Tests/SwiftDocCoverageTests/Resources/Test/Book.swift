import Foundation

enum Genre {
    case adventure
    case classics
    case comic
    case detective
    case fantacy
}

struct Book {
    let title: String
    let ISBN: Int
    let genre: Genre
}
