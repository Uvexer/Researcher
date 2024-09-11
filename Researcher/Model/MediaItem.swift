import Foundation

struct MediaItem: Codable {
    let id: String
    let description: String?
    let user: User
    let urls: URLs
}

