//
//  InventoryService.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/21.
//

import Foundation

final class InventoryService {
    static let artCacheFolderURL = FilesManager.cacheFolderURL.appendingPathComponent("artS", isDirectory: true)
    static let imageCacheFolderURL = artCacheFolderURL.appendingPathComponent("image", isDirectory: true)
    static let imageCacheFileURL = imageCacheFolderURL.appendingPathComponent("ImageCache.txt")
    static let videoCacheFolderURL = artCacheFolderURL.appendingPathComponent("video", isDirectory: true)
    static let videoCacheFileURL = videoCacheFolderURL.appendingPathComponent("VideoCache.txt")
    
    static let shared: InventoryService = .init()
    
    private init() {
        FilesManager.checkDirectory(url: InventoryService.imageCacheFolderURL)
        FilesManager.checkDirectory(url: InventoryService.videoCacheFolderURL)
    }
    
    func remove(art: ArtProtocol) {
        switch art.mediaType {
        case .image:
            if let imageArt = art as? ImageArt {
                removeImageArt(imageArt: imageArt)
                removeImage(imageArt)
            }
        case .video:
            if let videoArt = art as? VideoArt {
                removeVideoArt(videoArt: videoArt)
                removeVideo(videoArt)
            }
        }
    }
    
    func removeImageArt(imageArt: ImageArt) {
        let fileURL = InventoryService.imageCacheFolderURL.appendingPathComponent(imageArt.fileName)
        let thumbnailURL = InventoryService.imageCacheFolderURL.appendingPathComponent(imageArt.name + ".jpg")
        FilesManager.removeFile(url: fileURL)
        FilesManager.removeFile(url: thumbnailURL)
    }
    
    func removeVideoArt(videoArt: VideoArt) {
        let fileURL = InventoryService.videoCacheFolderURL.appendingPathComponent(videoArt.fileName)
        let thumbnailURL = InventoryService.videoCacheFolderURL.appendingPathComponent(videoArt.name + "jpg")
        FilesManager.removeFile(url: fileURL)
        FilesManager.removeFile(url: thumbnailURL)
    }
    
    func saveImage(data: Data, nft: NFTProtocol, template: Template) -> ImageArt {
        let date = Date()
        let timeInterval = Int(date.timeIntervalSince1970)
        let name = "\(timeInterval)"
        let fileName = "\(name).jpg"
        let imageArt = ImageArt(name: name, fileName: fileName, resource: .init(marketPlaceKind: .openSea, address: "", mediaType: .image, nft: nft.simple, data: .init(), permalink: nft.permalink, template: template), createdAt: timeInterval)
        let url = InventoryService.imageCacheFolderURL.appendingPathComponent(fileName)
        addImages(imageArt)
        try? data.write(to: url)
        return imageArt
    }
    
    func fetchImages() -> [ImageArt] {
        if let data = try? Data(contentsOf: InventoryService.imageCacheFileURL),
           let imagesArts = try? JSONDecoder().decode([ImageArt].self, from: data) {
            return imagesArts
        }
        return []
    }
    
    func addImages(_ imageArt: ImageArt) {
        var imagesArts = fetchImages()
        imagesArts.insert(imageArt, at: 0)
        overWriteImages(imagesArts)
    }
    
    func removeImage(_ imageArt: ImageArt) {
        var imagesArts = fetchImages()
        if let index = imagesArts.firstIndex(where: { $0.name == imageArt.name }) {
            imagesArts.remove(at: index)
        }
        overWriteImages(imagesArts)
    }
    
    private func overWriteImages(_ arts: [ImageArt]) {
        if let data = try? JSONEncoder().encode(arts) {
            try? data.write(to: InventoryService.imageCacheFileURL)
        }
    }
    
    func saveVideo(thumbData: Data, videoData: Data, nft: NFTProtocol, template: Template) -> VideoArt {
        let date = Date()
        let timeInterval = Int(date.timeIntervalSince1970)
        let name = "\(timeInterval)"
        let filename = "\(name).mov"
        let thumbName = "\(name).jpg"
        let videoURL = InventoryService.videoCacheFolderURL.appendingPathComponent(filename)
        let thumbNameURL = InventoryService.videoCacheFolderURL.appendingPathComponent(thumbName)
        let videoArt = VideoArt(name: name, fileName: filename, resource: .init(marketPlaceKind: .openSea, address: "", mediaType: .image, nft: nft.simple, data: .init(), permalink: nft.permalink, template: template), createdAt: timeInterval)
        addVideo(videoArt)
        try? videoData.write(to: videoURL)
        try? thumbData.write(to: thumbNameURL)
        return videoArt
    }
    
    func fetchVideos() -> [VideoArt] {
        if let data = try? Data(contentsOf: InventoryService.videoCacheFileURL),
           let videosArts = try? JSONDecoder().decode([VideoArt].self, from: data) {
            return videosArts
        }
        return []
    }
    
    func addVideo(_ videoArt: VideoArt) {
        var videosArts = fetchVideos()
        videosArts.insert(videoArt, at: 0)
        overWriteVideos(videosArts)
    }
    
    func removeVideo(_ videoArt: VideoArt) {
        var videoArts = fetchVideos()
        if let index = videoArts.firstIndex(where: { $0.name == videoArt.name }) {
            videoArts.remove(at: index)
        }
        overWriteVideos(videoArts)
    }
    
    private func overWriteVideos(_ arts: [VideoArt]) {
        if let data = try? JSONEncoder().encode(arts) {
            try? data.write(to: InventoryService.videoCacheFileURL)
        }
    }
}
