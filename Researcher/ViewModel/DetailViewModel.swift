import Foundation

class DetailViewModel {
    private let mediaItem: MediaItem
    
    var descriptionText: String {
        return mediaItem.description ?? "Описание отсутствует"
    }
    
    var authorText: String {
        return "Автор: \(mediaItem.user.name)"
    }
    
    var imageUrl: URL? {
        return URL(string: mediaItem.urls.full)
    }
    
    init(mediaItem: MediaItem) {
        self.mediaItem = mediaItem
    }
}

